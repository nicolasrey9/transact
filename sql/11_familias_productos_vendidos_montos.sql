/*11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
el año 2012.*/
use GD2015C1
select 
f.fami_detalle, 
count(distinct itf.item_producto) ProdsVendidosDiferentes,
sum(isnull(itf.item_cantidad * itf.item_precio,0)) MontoSinImpuestos

from Familia f 
join Producto p on p.prod_familia = f.fami_id
join Item_Factura itf on p.prod_codigo = itf.item_producto

where f.fami_id in (select prod_familia from Producto 
                    join Item_Factura on prod_codigo = item_producto
                    join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                    where YEAR(fact_fecha) = '2012'
                    group by prod_familia
                    having sum(item_cantidad*item_precio) > '20000')
GROUP by f.fami_detalle
order by 2 desc