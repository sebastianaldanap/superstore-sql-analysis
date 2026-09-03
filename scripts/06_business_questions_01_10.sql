-- =============================================
-- 06_business_questions_01_10.sql
-- Fase 6-7: Análisis de Negocio
-- =============================================

-- ============================================================
-- PREGUNTA 1: Top 3 y Bottom 3 sub-categorías por rentabilidad total
-- Insight: Tables es la sub-categoría más problemática (-17,725.59)
-- ============================================================
SELECT TOP 3 
    p.Sub_Category,
    SUM(f.Profit) AS Rentabilidad_Total
FROM Fact_Orders f
INNER JOIN Dim_Products p ON f.Product_ID = p.Product_ID
GROUP BY p.Sub_Category
ORDER BY Rentabilidad_Total DESC;

SELECT TOP 3 
    p.Sub_Category,
    SUM(f.Profit) AS Rentabilidad_Total
FROM Fact_Orders f
INNER JOIN Dim_Products p ON f.Product_ID = p.Product_ID
GROUP BY p.Sub_Category
ORDER BY Rentabilidad_Total ASC;


-- ============================================================
-- PREGUNTA 2: Categorías con >100 pedidos en pérdida, sobre el promedio general
-- Insight: Office Supplies (886) y Furniture (713) concentran las pérdidas
-- ============================================================
SELECT 
    p.Category,
    COUNT(*) AS Pedidos_Con_Perdida
FROM Fact_Orders f
INNER JOIN Dim_Products p ON f.Product_ID = p.Product_ID
WHERE f.Profit < 0
GROUP BY p.Category
HAVING COUNT(*) > 100
   AND COUNT(*) > (
        SELECT AVG(ConteoPorCategoria)
        FROM (
            SELECT COUNT(*) AS ConteoPorCategoria
            FROM Fact_Orders f2
            INNER JOIN Dim_Products p2 ON f2.Product_ID = p2.Product_ID
            WHERE f2.Profit < 0
            GROUP BY p2.Category
        ) AS Sub
   )
ORDER BY Pedidos_Con_Perdida DESC;


-- ============================================================
-- PREGUNTA 3: Margen de rentabilidad promedio por rango de descuento
-- Insight: la rentabilidad se vuelve negativa desde descuentos >20%
-- ============================================================
SELECT 
    CASE 
        WHEN f.Discount = 0 THEN 'Sin descuento'
        WHEN f.Discount <= 0.20 THEN 'Bajo (0-20%)'
        WHEN f.Discount <= 0.40 THEN 'Medio (21-40%)'
        WHEN f.Discount <= 0.60 THEN 'Alto (41-60%)'
        ELSE 'Muy alto (61%+)'
    END AS Rango_Descuento,
    COUNT(*) AS Cantidad_Lineas,
    AVG(f.Profit) AS Rentabilidad_Promedio
FROM Fact_Orders f
GROUP BY 
    CASE 
        WHEN f.Discount = 0 THEN 'Sin descuento'
        WHEN f.Discount <= 0.20 THEN 'Bajo (0-20%)'
        WHEN f.Discount <= 0.40 THEN 'Medio (21-40%)'
        WHEN f.Discount <= 0.60 THEN 'Alto (41-60%)'
        ELSE 'Muy alto (61%+)'
    END
ORDER BY Rentabilidad_Promedio DESC;


-- ============================================================
-- PREGUNTA 4: Tiempo promedio de despacho por modo de envío y región
-- Insight: tiempos consistentes entre regiones, West levemente más lento en Standard Class
-- ============================================================
SELECT 
    f.Ship_Mode,
    f.Region,
    AVG(DATEDIFF(DAY, f.Order_Date, f.Ship_Date)) AS Dias_Promedio_Despacho,
    COUNT(*) AS Cantidad_Pedidos
FROM Fact_Orders f
GROUP BY f.Ship_Mode, f.Region
ORDER BY f.Ship_Mode, Dias_Promedio_Despacho DESC;


-- ============================================================
-- PREGUNTA 5: Top 10% de clientes por rentabilidad generada (NTILE)
-- Insight: Tamara Chand lidera muy por encima del resto del top decil
-- ============================================================
WITH RentabilidadPorCliente AS (
    SELECT 
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        SUM(f.Profit) AS Rentabilidad_Total,
        NTILE(10) OVER (ORDER BY SUM(f.Profit) DESC) AS Decil
    FROM Fact_Orders f
    INNER JOIN Dim_Customers c ON f.Customer_ID = c.Customer_ID
    GROUP BY c.Customer_ID, c.Customer_Name, c.Segment
)
SELECT Customer_ID, Customer_Name, Segment, Rentabilidad_Total
FROM RentabilidadPorCliente
WHERE Decil = 1
ORDER BY Rentabilidad_Total DESC;


-- ============================================================
-- PREGUNTA 6: Top 5 productos más rentables por categoría (RANK)
-- Insight: Canon imageCLASS 2200 genera 25,199.94 - más del triple del 2° lugar
-- ============================================================
WITH RankingProductos AS (
    SELECT 
        p.Category,
        p.Product_Name,
        SUM(f.Profit) AS Rentabilidad_Total,
        RANK() OVER (PARTITION BY p.Category ORDER BY SUM(f.Profit) DESC) AS Ranking
    FROM Fact_Orders f
    INNER JOIN Dim_Products p ON f.Product_ID = p.Product_ID
    GROUP BY p.Category, p.Product_Name
)
SELECT Category, Product_Name, Rentabilidad_Total, Ranking
FROM RankingProductos
WHERE Ranking <= 5
ORDER BY Category, Ranking;


-- ============================================================
-- PREGUNTA 7: % de participación de cada categoría en ventas por región
-- Insight: Technology lidera en 3 de 4 regiones; Office Supplies siempre último
-- ============================================================
WITH VentasPorRegionCategoria AS (
    SELECT 
        f.Region,
        p.Category,
        SUM(f.Sales) AS Ventas_Categoria
    FROM Fact_Orders f
    INNER JOIN Dim_Products p ON f.Product_ID = p.Product_ID
    GROUP BY f.Region, p.Category
)
SELECT 
    Region,
    Category,
    Ventas_Categoria,
    SUM(Ventas_Categoria) OVER (PARTITION BY Region) AS Ventas_Totales_Region,
    CAST(Ventas_Categoria * 100.0 / SUM(Ventas_Categoria) OVER (PARTITION BY Region) AS DECIMAL(5,2)) AS Porcentaje_Participacion
FROM VentasPorRegionCategoria
ORDER BY Region, Porcentaje_Participacion DESC;


-- ============================================================
-- PREGUNTA 8: Cliente con mayor gasto histórico vs. promedio de su segmento
-- Insight: Sean Miller (Home Office) gasta 9x el promedio de su segmento
-- ============================================================
WITH GastoPorCliente AS (
    SELECT 
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        SUM(f.Sales) AS Gasto_Total
    FROM Fact_Orders f
    INNER JOIN Dim_Customers c ON f.Customer_ID = c.Customer_ID
    GROUP BY c.Customer_ID, c.Customer_Name, c.Segment
)
SELECT TOP 1
    g.Customer_Name,
    g.Segment,
    g.Gasto_Total,
    (SELECT AVG(g2.Gasto_Total) 
     FROM GastoPorCliente g2 
     WHERE g2.Segment = g.Segment) AS Promedio_Segmento,
    g.Gasto_Total - (SELECT AVG(g2.Gasto_Total) 
                      FROM GastoPorCliente g2 
                      WHERE g2.Segment = g.Segment) AS Diferencia_Vs_Promedio
FROM GastoPorCliente g
ORDER BY g.Gasto_Total DESC;


-- ============================================================
-- PREGUNTA 9: Rentabilidad mensual y acumulada (running total)
-- Insight: crecimiento sostenido 2014-2017, con aceleración marcada en 2016-2017
-- ============================================================
WITH RentabilidadMensual AS (
    SELECT 
        DATEPART(YEAR, f.Order_Date) AS Anio,
        DATEPART(MONTH, f.Order_Date) AS Mes,
        SUM(f.Profit) AS Rentabilidad_Mes
    FROM Fact_Orders f
    GROUP BY DATEPART(YEAR, f.Order_Date), DATEPART(MONTH, f.Order_Date)
)
SELECT 
    Anio,
    Mes,
    Rentabilidad_Mes,
    SUM(Rentabilidad_Mes) OVER (ORDER BY Anio, Mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Rentabilidad_Acumulada
FROM RentabilidadMensual
ORDER BY Anio, Mes;


-- ============================================================
-- PREGUNTA 10: Eficiencia de rentabilidad por unidad de descuento, por segmento
-- Insight: Home Office es el más eficiente pese a tener menor rentabilidad total
-- ============================================================
WITH MetricasPorSegmento AS (
    SELECT 
        c.Segment,
        SUM(f.Profit) AS Rentabilidad_Total,
        SUM(f.Discount) AS Descuento_Acumulado
    FROM Fact_Orders f
    INNER JOIN Dim_Customers c ON f.Customer_ID = c.Customer_ID
    GROUP BY c.Segment
)
SELECT 
    Segment,
    Rentabilidad_Total,
    Descuento_Acumulado,
    CAST(Rentabilidad_Total / NULLIF(Descuento_Acumulado, 0) AS DECIMAL(10,2)) AS Eficiencia_Rentabilidad_Por_Descuento
FROM MetricasPorSegmento
ORDER BY Eficiencia_Rentabilidad_Por_Descuento DESC;


-- ============================================================
-- VIEW EXTRA: Vista de reporte reutilizable
-- Insight: el problema de rentabilidad negativa está en Furniture 
-- específicamente en la región Central, no en la categoría a nivel general
-- ============================================================
CREATE OR ALTER VIEW vw_RentabilidadPorCategoriaRegion AS
SELECT 
    f.Region,
    p.Category,
    SUM(f.Sales) AS Ventas_Totales,
    SUM(f.Profit) AS Rentabilidad_Total,
    CAST(SUM(f.Profit) * 100.0 / NULLIF(SUM(f.Sales), 0) AS DECIMAL(5,2)) AS Margen_Porcentual
FROM Fact_Orders f
INNER JOIN Dim_Products p ON f.Product_ID = p.Product_ID
GROUP BY f.Region, p.Category;
GO

SELECT * FROM vw_RentabilidadPorCategoriaRegion
ORDER BY Region, Margen_Porcentual DESC;