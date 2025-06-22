/*10. Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo.*/
select 
p.prod_codigo,
(select top 1 fact_cliente from Factura 
join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
where item_producto = p.prod_codigo
group by fact_cliente
order by sum(item_cantidad) desc) MaximoComprador

from Producto p

where p.prod_codigo in 
    (select top 10 item_producto from Item_Factura
    group by item_producto
    order by sum(item_cantidad) desc)
or p.prod_codigo IN
    (select top 10 item_producto from Item_Factura
    group by item_producto
    order by sum(item_cantidad))

group by p.prod_codigo