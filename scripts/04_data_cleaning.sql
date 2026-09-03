-- =============================================
-- 04_data_cleaning.sql
-- Fase 5 (Parte A): Limpieza de Datos
-- =============================================

-- Objetivo: eliminar la línea duplicada real detectada en Fase 4
-- (Order_ID US-2014-150119, Product_ID FUR-CH-10002965, 
-- Row_ID 3406 y 3407 son idénticas en todos sus campos)

-- Verificación previa (debe devolver 2 filas idénticas antes de borrar)
SELECT * FROM Superstore 
WHERE Row_ID IN (3406, 3407);

-- Eliminamos solo una de las dos ocurrencias, dejando la de menor Row_ID
-- Nota: se usa Row_ID (único por fila) y no Order_ID/Product_ID, porque 
-- ese par también identifica 7 casos de líneas legítimas distintas que 
-- no deben eliminarse (ver investigación en 03_data_quality_checks.sql)
DELETE FROM Superstore
WHERE Row_ID = 3407;

-- Validación posterior: debe devolver 9993
SELECT COUNT(*) AS TotalFilas FROM Superstore;