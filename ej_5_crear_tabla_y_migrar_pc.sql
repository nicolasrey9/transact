/*
Realizar un procedimiento que complete con los datos existentes en el modelo
provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
Create table Fact_table
( anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),****
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2)
)
Alter table Fact_table
Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)
*/
CREATE PROCEDURE ej_5_crear_tabla_y_migrar AS 
BEGIN

CREATE TABLE fact_table 
(anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2),
CONSTRAINT pk_fact_table PRIMARY KEY (anio,mes,familia,rubro,zona,cliente,producto)
)

INSERT INTO fact_table
SELECT YEAR(f.fact_fecha), MONTH(f.fact_fecha), P.prod_familia, p.prod_rubro,
d.depa_zona, f.fact_cliente, p.prod_codigo, SUM(i.item_cantidad), 
SUM(i.item_cantidad * i.item_precio) 
FROM factura f 
INNER JOIN Item_Factura i ON 
f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero 
INNER JOIN producto p ON i.item_producto = p.prod_codigo
INNER JOIN Empleado v ON f.fact_vendedor = v.empl_codigo 
INNER JOIN Departamento d ON v.empl_departamento = d.depa_codigo 
GROUP BY YEAR(f.fact_fecha), MONTH(f.fact_fecha), P.prod_familia, p.prod_rubro, d.depa_zona, 
fact_cliente, p.prod_codigo 

END 
GO