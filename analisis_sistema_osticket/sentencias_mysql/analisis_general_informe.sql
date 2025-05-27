-- Tabla de funcionarios
SELECT * FROM elyon.COMUN.dbo.funcionarios;

-- Subcentros de costos ignorados
SELECT DISTINCT FUNC_COD_CCOSTO, FUNC_NOM_CCOSTO 
FROM elyon.COMUN.dbo.funcionarios 
WHERE FUNC_COD_CCOSTO IN (229,230,231,1344,1877);

-- Funcionarios de los subcentros de costos ignorados
SELECT FUNC_NOMBRES, FUNC_NOM_CCOSTO 
FROM elyon.COMUN.dbo.funcionarios 
WHERE FUNC_COD_CCOSTO IN (229,230,231,1344,1877)
ORDER BY FUNC_FECHA_ING DESC;

-- Cargos/Sub Centros - Estamentos
SELECT DISTINCT a.FUNC_DESC_CARGO cargo_nombre, a.FUNC_NOM_CCOSTO subcentro_costo, c.esta_nombre estamento 
FROM elyon.COMUN.dbo.funcionarios a
INNER JOIN COMUN.dbo.cargo_estamento b ON a.FUNC_COD_CCOSTO=b.FUNC_COD_CCOSTO AND a.FUNC_COD_CARGO=b.FUNC_COD_CARGO
INNER JOIN COMUN.dbo.estamento c ON b.esta_codigo=c.esta_codigo
--WHERE c.esta_codigo=0

-- Cargos/Sub Centros - Estamentos (SIN DEFINIR)
SELECT DISTINCT a.FUNC_DESC_CARGO cargo_nombre, a.FUNC_NOM_CCOSTO subcentro_costo, c.esta_nombre estamento 
FROM elyon.COMUN.dbo.funcionarios a
LEFT JOIN COMUN.dbo.cargo_estamento b ON a.FUNC_COD_CCOSTO=b.FUNC_COD_CCOSTO AND a.FUNC_COD_CARGO=b.FUNC_COD_CARGO
LEFT JOIN COMUN.dbo.estamento c ON b.esta_codigo=c.esta_codigo
WHERE c.esta_codigo IS NULL

-- Total de cargos y subcentros
SELECT DISTINCT a.FUNC_DESC_CARGO cargo_nombre, a.FUNC_NOM_CCOSTO subcentro_costo, c.esta_nombre estamento 
FROM elyon.COMUN.dbo.funcionarios a
LEFT JOIN COMUN.dbo.cargo_estamento b ON a.FUNC_COD_CCOSTO=b.FUNC_COD_CCOSTO AND a.FUNC_COD_CARGO=b.FUNC_COD_CARGO
LEFT JOIN COMUN.dbo.estamento c ON b.esta_codigo=c.esta_codigo