-- =============================================
-- 05_create_dimensional_model.sql
-- Fase 5 (Parte B): Modelo Dimensional
-- =============================================

-- Limpieza de intentos previos (permite re-ejecutar el script sin errores)
DROP TABLE IF EXISTS Fact_Orders;
DROP TABLE IF EXISTS Dim_Customers;
DROP TABLE IF EXISTS Dim_Products;

-- ---------- Dim_Customers ----------
-- Objetivo: aislar SOLO los atributos que realmente identifican al cliente
-- Nota de diseño: City/State/Postal_Code/Region se excluyen a propósito,
-- porque pertenecen a la dirección de ENVÍO de cada pedido, no al cliente
-- (un mismo Customer_ID puede tener hasta 5 ubicaciones distintas en el 
-- dataset, según se validó al intentar la primera versión de este modelo)
CREATE TABLE Dim_Customers (
    Customer_ID     NVARCHAR(50) PRIMARY KEY,
    Customer_Name   NVARCHAR(50),
    Segment         NVARCHAR(50)
);

INSERT INTO Dim_Customers (Customer_ID, Customer_Name, Segment)
SELECT DISTINCT Customer_ID, Customer_Name, Segment
FROM Superstore;

-- ---------- Dim_Products ----------
-- Objetivo: aislar atributos de producto
-- Nota de diseño: el dataset original reutiliza algunos Product_ID para 
-- productos con nombre distinto (defecto conocido de Superstore/Tableau).
-- Se usa ROW_NUMBER() para conservar solo 1 versión por Product_ID, 
-- priorizando el registro con menor Row_ID (más antiguo)
CREATE TABLE Dim_Products (
    Product_ID      NVARCHAR(50) PRIMARY KEY,
    Category        NVARCHAR(50),
    Sub_Category    NVARCHAR(50),
    Product_Name    NVARCHAR(150)
);

WITH ProductosRankeados AS (
    SELECT 
        Product_ID, Category, Sub_Category, Product_Name,
        ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Row_ID) AS rn
    FROM Superstore
)
INSERT INTO Dim_Products (Product_ID, Category, Sub_Category, Product_Name)
SELECT Product_ID, Category, Sub_Category, Product_Name
FROM ProductosRankeados
WHERE rn = 1;

-- ---------- Fact_Orders ----------
-- Objetivo: tabla de hechos con métricas + ubicación de envío + llaves foráneas
CREATE TABLE Fact_Orders (
    Row_ID          SMALLINT PRIMARY KEY,
    Order_ID        NVARCHAR(50),
    Order_Date      DATE,
    Ship_Date       DATE,
    Ship_Mode       NVARCHAR(50),
    Customer_ID     NVARCHAR(50) FOREIGN KEY REFERENCES Dim_Customers(Customer_ID),
    Product_ID      NVARCHAR(50) FOREIGN KEY REFERENCES Dim_Products(Product_ID),
    City            NVARCHAR(50),
    State           NVARCHAR(50),
    Postal_Code     NVARCHAR(10),
    Region          NVARCHAR(50),
    Sales           DECIMAL(10,2),
    Quantity        TINYINT,
    Discount        DECIMAL(4,2),
    Profit          DECIMAL(10,2)
);

INSERT INTO Fact_Orders (Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Product_ID, City, State, Postal_Code, Region, Sales, Quantity, Discount, Profit)
SELECT Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Product_ID, City, State, Postal_Code, Region, Sales, Quantity, Discount, Profit
FROM Superstore;

-- ---------- Validación final ----------
SELECT COUNT(*) AS Total_Dim_Customers FROM Dim_Customers;   -- Esperado: 793
SELECT COUNT(*) AS Total_Dim_Products FROM Dim_Products;     -- Esperado: 1,862
SELECT COUNT(*) AS Total_Fact_Orders FROM Fact_Orders;       -- Esperado: 9,993

-- Verifica que el JOIN entre las 3 tablas reconstruya el total original
SELECT COUNT(*) AS TotalJoined
FROM Fact_Orders f
INNER JOIN Dim_Customers c ON f.Customer_ID = c.Customer_ID
INNER JOIN Dim_Products p ON f.Product_ID = p.Product_ID;
-- Esperado: 9,993 (confirma que no hubo pérdida de registros en el modelo)