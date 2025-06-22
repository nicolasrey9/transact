/*16. Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran
en la empresa, se pide una consulta SQL que retorne aquellos clientes cuyas compras son
inferiores a 1/3 del promedio de ventas del producto que más se vendió en el 2012.
Además mostrar
1. Nombre del Cliente
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
mostrar solamente el de menor código) para ese cliente.
Aclaraciones:
La composición es de 2 niveles, es decir, un producto compuesto solo se compone de
productos no compuestos.
Los clientes deben ser ordenados por código de provincia ascendente.*/
select 
c.clie_razon_social NombreCliente,
sum(isnull(if1.item_cantidad,0)) UnidadesTotalesCompradas,
(select top 1 item_producto from Item_Factura join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
and fact_cliente = c.clie_codigo and YEAR(fact_fecha) = '2012'
group by item_producto
order by sum(item_cantidad) desc,item_producto) CodigoProductoQueMasCompro

from Cliente c
join Factura f on f.fact_cliente = c.clie_codigo and YEAR(f.fact_fecha) = '2012'
join Item_Factura if1 on if1.item_tipo+if1.item_sucursal+if1.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero

group by c.clie_codigo, c.clie_razon_social, c.clie_domicilio

having sum(if1.item_cantidad*if1.item_precio) * 3 < (select top 1 avg(item_cantidad*item_precio) 
                            from Item_Factura 
                            join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero and YEAR(fact_fecha) = '2012'
                            group by item_producto
                            order by sum(item_cantidad*item_precio) desc
                            )
order by c.clie_domicilio