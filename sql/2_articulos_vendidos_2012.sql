/*2. Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
cantidad vendida.*/
select prod_codigo, prod_detalle, sum(item_cantidad) paraChequear
from Producto 
join Item_Factura on prod_codigo = item_producto
join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
where year(fact_fecha) = '2012'
group by prod_codigo, prod_detalle
order by sum(item_cantidad) desc