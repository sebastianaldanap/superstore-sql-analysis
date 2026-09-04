# Análisis de Rentabilidad y Eficiencia Operativa — Superstore (SQL Server)

## 1. Descripción del Proyecto
Proyecto de análisis de datos desarrollado en SQL Server (T-SQL) sobre 
~9,993 transacciones de una cadena retail (Superstore, 2014-2017), con foco 
en identificar patrones de rentabilidad, eficiencia de descuentos y 
comportamiento de clientes. Desarrollado como proyecto final del curso 
"SQL for Data Analyst" (Data Academy Latam) y como pieza de portafolio 
para procesos de selección como Data Analyst / BI Analyst.

## 2. Objetivos

**Objetivo General:**  
Analizar el desempeño de ventas, rentabilidad y eficiencia logística de 
Superstore mediante SQL Server, generando hallazgos y recomendaciones 
accionables aplicables a distintas áreas del negocio.

**Objetivos Específicos:**
- Identificar las categorías y sub-categorías con mayor y menor rentabilidad.
- Evaluar el impacto del descuento sobre el margen de ganancia.
- Medir la eficiencia del proceso de despacho por modo de envío y región.
- Segmentar clientes según su contribución a la rentabilidad total.
- Detectar patrones estacionales o regionales en el volumen de pedidos.

## 3. Tecnologías Utilizadas
- Microsoft SQL Server (T-SQL)
- SQL Server Management Studio (SSMS)
- Git y GitHub (control de versiones y publicación)
- Funciones y técnicas: `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, `HAVING`, 
  `CASE WHEN`, `INNER JOIN`, subconsultas simples y correlacionadas, CTEs, 
  funciones de agregación, `ROW_NUMBER()`, `RANK()`, `NTILE()`, funciones 
  de ventana con `SUM() OVER()`, Views

## 4. Dataset Utilizado
**Fuente:** [Sample Superstore Dataset – Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)  
**Registros:** 9,994 originales (9,993 tras limpieza)  
**Columnas:** 21  

El dataset contiene información de pedidos, clientes, productos, envíos y 
métricas financieras de una cadena retail en Estados Unidos. Ver el 
diccionario de datos completo en 
[`/documentation/diccionario_datos.md`](./documentation/diccionario_datos.md).

## 5. Metodología
1. **Carga de datos:** Importación del archivo `Superstores.csv` a SQL Server 
   mediante el asistente "Import Flat File" de SSMS.
2. **Exploración y calidad de datos:** Validación de estructura, nulos, 
   duplicados, categorías, valores atípicos y consistencia de fechas.
3. **Limpieza:** Eliminación de 1 registro duplicado real detectado 
   (de 8 casos similares investigados, solo 1 resultó ser un duplicado exacto).
4. **Modelado dimensional:** Normalización del dataset plano en un modelo 
   de tabla de hechos + dimensiones (`Fact_Orders`, `Dim_Customers`, 
   `Dim_Products`), resolviendo dos hallazgos de diseño: la ubicación es un 
   atributo del pedido (no del cliente), y algunos `Product_ID` estaban 
   duplicados con nombres distintos en el dataset original.
5. **Análisis:** Desarrollo de 10 preguntas de negocio progresivas 
   (de nivel básico a avanzado) más una vista de reporte reutilizable.

## 6. Estructura del Repositorio

```
superstore-sql-analysis/
├── README.md
├── dataset/
│   └── Superstores.csv
├── scripts/
│   ├── 01_create_staging_table.sql
│   ├── 02_load_staging_data.sql
│   ├── 03_data_quality_checks.sql
│   ├── 04_data_cleaning.sql
│   ├── 05_create_dimensional_model.sql
│   └── 06_business_questions_01_10.sql
├── screenshots/
│   ├── banner_SQL.png
│   └── (capturas numeradas de calidad de datos, modelo dimensional y preguntas de negocio)
└── documentation/
    └── diccionario_datos.md
```

