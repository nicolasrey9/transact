/*22. Escriba una consulta sql que retorne una estadistica de venta para todos los rubros por
trimestre contabilizando todos los años. Se mostraran como maximo 4 filas por rubro (1
por cada trimestre).
Se deben mostrar 4 columnas:
 Detalle del rubro
 Numero de trimestre del año (1 a 4)
 Cantidad de facturas emitidas en el trimestre en las que se haya vendido al
menos un producto del rubro
 Cantidad de productos diferentes del rubro vendidos en el trimestre
El resultado debe ser ordenado alfabeticamente por el detalle del rubro y dentro de cada
rubro primero el trimestre en el que mas facturas se emitieron.
No se deberan mostrar aquellos rubros y trimestres para los cuales las facturas emitiadas
no superen las 100.
En ningun momento se tendran en cuenta los productos compuestos para esta
estadistica*/

----------NO CONFIO EN NINGUNA DE LAS 2 SOLUCIONES---------------------
select 
r.rubr_detalle,
FLOOR((MONTH(f.fact_fecha)-1) / 3) +1 as Trimestre,
count(f.fact_numero) Facturas,
count(distinct it.item_producto) ProductosDiferentesVendidos

from Rubro r
left join Producto p on p.prod_rubro = r.rubr_id and p.prod_codigo not in (select comp_producto from Composicion)
left join Item_Factura it on it.item_producto = p.prod_codigo
join Factura f on it.item_tipo+it.item_sucursal+it.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero


group by r.rubr_id,r.rubr_detalle,f.fact_fecha

having count(f.fact_numero) > 100

order by 1 desc,3 desc

--------Nico Docs-------------------
select rubr_detalle, FLOOR((MONTH(fact_fecha)-1) / 3) +1 [Trimestre], count(fact_numero) [Cantidad de facturas],
count(distinct item_producto)[Cantidad de productos] from Rubro
left join Producto on prod_rubro=rubr_id and prod_codigo not in (select comp_producto from Composicion)
left join Item_Factura on item_producto=prod_codigo
join Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
GROUP by rubr_id, rubr_detalle, FLOOR((MONTH(fact_fecha)-1) / 3) +1
having count(fact_numero) > 100
order by rubr_detalle, count(fact_numero) desc