# Diccionario de Datos — Superstore

## Fuente de Datos
Kaggle — "Superstore Dataset Final"  
https://www.kaggle.com/datasets/vivek468/superstore-dataset-final

## Descripción General
Registro transaccional de pedidos de una cadena retail en Estados Unidos, 
con información de cliente, producto, ubicación geográfica, fechas de 
pedido/envío y métricas financieras (ventas, descuento, ganancia) a nivel 
de línea de producto por pedido.

## Número de Registros
9,994 originales → 9,993 tras limpieza (Fase 5)

## Número de Columnas
21 originales, todas utilizadas en el modelo dimensional final

## Diccionario de Columnas

| # | Columna | Tipo de dato (T-SQL) | Descripción | Uso en el análisis |
|---|---|---|---|---|
| 1 | Row_ID | `smallint` | Identificador único de línea | Llave primaria de Fact_Orders |
| 2 | Order_ID | `nvarchar(50)` | Identificador del pedido (se repite por línea de producto) | Agrupación de pedidos, `COUNT(DISTINCT)` |
| 3 | Order_Date | `date` | Fecha del pedido | Análisis de tendencias, cálculo de tiempo de despacho |
| 4 | Ship_Date | `date` | Fecha de despacho | Cálculo de tiempo de despacho (`DATEDIFF`) |
| 5 | Ship_Mode | `nvarchar(50)` | Modo de envío | Dimensión de eficiencia logística |
| 6 | Customer_ID | `nvarchar(50)` | Identificador del cliente | Llave foránea hacia Dim_Customers |
| 7 | Customer_Name | `nvarchar(50)` | Nombre del cliente | Atributo descriptivo |
| 8 | Segment | `nvarchar(50)` | Segmento de cliente | Dimensión de segmentación |
| 9 | Country | `nvarchar(50)` | País | Excluido del análisis (sin variabilidad, solo EE.UU.) |
| 10 | City | `nvarchar(50)` | Ciudad de envío | Análisis geográfico (vive en Fact_Orders, no en Dim_Customers) |
| 11 | State | `nvarchar(50)` | Estado de envío | Análisis geográfico |
| 12 | Postal_Code | `nvarchar(10)` | Código postal de envío | Análisis geográfico de detalle |
| 13 | Region | `nvarchar(50)` | Región de envío | Dimensión clave para agrupaciones geográficas |
| 14 | Product_ID | `nvarchar(50)` | Identificador del producto | Llave foránea hacia Dim_Products |
| 15 | Category | `nvarchar(50)` | Categoría del producto | Dimensión principal de rentabilidad |
| 16 | Sub_Category | `nvarchar(50)` | Sub-categoría del producto | Nivel de detalle adicional |
| 17 | Product_Name | `nvarchar(150)` | Nombre del producto | Atributo descriptivo |
| 18 | Sales | `decimal(10,2)` | Monto de venta de la línea | Métrica base de agregación |
| 19 | Quantity | `tinyint` | Cantidad de unidades | Métrica de volumen |
| 20 | Discount | `decimal(4,2)` | Porcentaje de descuento aplicado | Métrica para correlación con rentabilidad |
| 21 | Profit | `decimal(10,2)` | Ganancia de la línea (puede ser negativa) | Métrica clave de rentabilidad |

## Notas de Diseño del Modelo Dimensional

- **Ubicación como atributo del pedido, no del cliente:** durante la 
  construcción del modelo se detectó que un mismo `Customer_ID` puede tener 
  múltiples ubicaciones distintas (hasta 5 en algunos casos), correspondientes 
  a distintas direcciones de envío. Por esta razón, `City`, `State`, 
  `Postal_Code` y `Region` se ubicaron en `Fact_Orders`, no en `Dim_Customers`.

- **Deduplicación de Product_ID:** el dataset original reutiliza algunos 
  `Product_ID` para productos con nombres distintos (defecto heredado del 
  dataset original de Tableau, republicado en Kaggle). Se resolvió con 
  `ROW_NUMBER()` para conservar una sola versión por producto en `Dim_Products`.

- **Eliminación de duplicado real:** se detectó y eliminó 1 registro 
  duplicado exacto (Row_ID 3406/3407), diferenciándolo de 7 casos similares 
  que resultaron ser líneas de pedido legítimas y distintas.