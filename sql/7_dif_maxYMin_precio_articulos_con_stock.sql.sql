/*7. Generar una consulta que muestre para cada artículo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
stock.*/
select 
p.prod_codigo CodigoArticulo,
p.prod_detalle DetalleArticulo,
max(itf.item_precio) Maximo,
min(itf.item_precio) Minimo,
(max(itf.item_precio) - min(itf.item_precio)) * 100/min(itf.item_precio) DiferenciaPorcentual

from Producto p 
join Item_Factura itf on p.prod_codigo = itf.item_producto

where p.prod_codigo in (select stoc_producto from STOCK where stoc_cantidad > 0)

group by p.prod_codigo, p.prod_detalle