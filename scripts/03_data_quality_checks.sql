-- =============================================
-- 03_data_quality_checks.sql
-- Fase 4: Exploración y Calidad de Datos
-- =============================================

-- 1. Validación de estructura
SELECT COUNT(*) AS TotalFilas FROM Superstore;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstore';

-- 2. Valores nulos en campos clave
SELECT 
    SUM(CASE WHEN Postal_Code IS NULL THEN 1 ELSE 0 END) AS Nulos_PostalCode,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Nulos_CustomerID,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Nulos_Sales,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Nulos_OrderDate
FROM Superstore;

-- 3a. Duplicados exactos (misma línea de pedido repetida)
SELECT Order_ID, Product_ID, COUNT(*) AS Repeticiones
FROM Superstore
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1;

-- 3b. Investigación detallada de los casos encontrados en 3a
-- (se valida si son duplicados reales o líneas legítimas distintas)
SELECT *
FROM Superstore
WHERE Order_ID IN (
    'US-2014-150119','CA-2016-137043','CA-2015-103135','CA-2016-140571',
    'CA-2016-129714','CA-2017-152912','CA-2017-118017','US-2016-123750'
)
ORDER BY Order_ID, Product_ID;

-- 3c. Pedidos únicos vs. líneas totales (no confundir ambos conceptos)
SELECT COUNT(*) AS LineasTotales, COUNT(DISTINCT Order_ID) AS PedidosUnicos
FROM Superstore;

-- 4. Categorías / posibles inconsistencias de escritura
SELECT DISTINCT Category FROM Superstore;
SELECT DISTINCT Sub_Category FROM Superstore;
SELECT DISTINCT Region FROM Superstore;
SELECT DISTINCT Ship_Mode FROM Superstore;
SELECT DISTINCT Segment FROM Superstore;

-- 5. Valores atípicos (outliers) en métricas financieras
SELECT 
    MIN(Profit) AS Profit_Min, MAX(Profit) AS Profit_Max,
    MIN(Discount) AS Discount_Min, MAX(Discount) AS Discount_Max,
    MIN(Sales) AS Sales_Min, MAX(Sales) AS Sales_Max
FROM Superstore;

-- 6. Validación lógica de fechas (el envío no puede ser antes del pedido)
SELECT Order_ID, Order_Date, Ship_Date
FROM Superstore
WHERE Ship_Date < Order_Date;

-- =============================================
-- RESUMEN DE HALLAZGOS
-- =============================================
-- - Estructura: 9,994 filas, 21 columnas - correcto
-- - Nulos: 0 en todos los campos clave validados
-- - Duplicados: 1 duplicado exacto real (Order_ID US-2014-150119, 
--   Product_ID FUR-CH-10002965, Row_ID 3406/3407 idénticos). 
--   Los otros 7 casos de Order_ID+Product_ID repetido son líneas 
--   legítimas distintas (mismo producto, distinta cantidad/monto).
-- - Categorías: sin inconsistencias de escritura
-- - Profit negativo: confirmado como dato válido de negocio, no error
-- - Fechas: 0 casos de fecha de envío anterior a la de pedido