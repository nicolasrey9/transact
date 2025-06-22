/*12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. Se deberán mostrar
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.*/
use GD2015C1
select 
p.prod_detalle,
count(distinct f.fact_cliente) ClientesDistintos,
avg(itf.item_precio) ImportePromedio,
count(distinct s.stoc_deposito) CantDepositosConStock,
sum(isnull(s.stoc_cantidad,0)) StockActualEnTodos

from Producto p
left join Item_Factura itf on p.prod_codigo = itf.item_producto
join Factura f on itf.item_tipo+itf.item_sucursal+itf.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
left join STOCK s on s.stoc_producto = p.prod_codigo and s.stoc_cantidad > 0

where p.prod_codigo in (select item_producto 
                        from Item_Factura 
                        join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                        where year(fact_fecha) = '2012'
                        group by item_producto)

group by p.prod_detalle,p.prod_codigo
order by sum(itf.item_precio * itf.item_cantidad) desc

-----------------Version Nico en Doc----------------------------
select prod_detalle, count(distinct fact_cliente), avg(item_precio),
(select count(stoc_deposito) from stock where stoc_producto=prod_codigo
and ISNULL(stoc_cantidad, 0) > 0),
(select isnull(sum(stoc_cantidad), 0) from stock where stoc_producto=prod_codigo),
sum(item_cantidad * item_precio) as monto_vendido
from Producto join Item_Factura on prod_codigo=item_producto
join Factura on item_numero+item_sucursal+item_tipo =fact_numero+fact_sucursal+fact_tipo
	group by prod_detalle, prod_codigo
having prod_codigo in (select item_producto from Item_Factura
join Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo where year(fact_fecha) = 2012
group by item_producto)
order by sum(item_cantidad * item_precio) desc