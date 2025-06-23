/*21. Escriba una consulta sql que retorne para todos los años, en los cuales se haya hecho al
menos una factura, la cantidad de clientes a los que se les facturo de manera incorrecta
al menos una factura y que cantidad de facturas se realizaron de manera incorrecta. Se
considera que una factura es incorrecta cuando la diferencia entre el total de la factura
menos el total de impuesto tiene una diferencia mayor a $ 1 respecto a la sumatoria de
los costos de cada uno de los items de dicha factura. Las columnas que se deben mostrar
son:
 Año
 Clientes a los que se les facturo mal en ese año
 Facturas mal realizadas en ese año*/
select 
year(f.fact_fecha) Anio,
count(distinct f.fact_cliente) CantClientesMalFacturados,
count(distinct f.fact_numero+f.fact_tipo+f.fact_sucursal) FacturasMalRealizadas

from Factura f

where f.fact_numero in (
            select fact_numero 
            from Factura 
            join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
            where YEAR(fact_fecha) = YEAR(f.fact_fecha)
            group by fact_numero, fact_total, fact_total_impuestos
            having (fact_total - fact_total_impuestos - sum(item_precio * item_cantidad)) > 1
            )

group by year(f.fact_fecha)

----------Version Nico en Docs (tiene SELECT en FROM)-------------------------
select 
year(f.fact_fecha), 

(select count(distinct clientes) from (select fact_cliente clientes from Factura join Item_Factura on
item_numero+item_sucursal+item_tipo=
fact_numero+fact_sucursal+fact_tipo where year(fact_fecha)=year(f.fact_fecha) group by fact_numero,fact_sucursal,
fact_tipo,fact_total, fact_total_impuestos, fact_cliente
having (fact_total-fact_total_impuestos - sum(item_precio*item_cantidad)) > 1) as t) CLIENTES_MAL,

(select count(*) from (select 1 facturas from Factura join Item_Factura on item_numero+item_sucursal+item_tipo=
fact_numero+fact_sucursal+fact_tipo where year(fact_fecha)=year(f.fact_fecha)
group by fact_numero,fact_sucursal,fact_tipo,fact_total, fact_total_impuestos
having (fact_total-fact_total_impuestos - sum(item_precio*item_cantidad)) > 1) as t) FACTURAS_MAL 

from Factura f
group by year(f.fact_fecha)

