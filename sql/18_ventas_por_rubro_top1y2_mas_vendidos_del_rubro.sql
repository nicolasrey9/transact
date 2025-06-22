/*18. Escriba una consulta que retorne una estadística de ventas para todos los rubros.
La consulta debe retornar:
DETALLE_RUBRO: Detalle del rubro
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
PROD1: Código del producto más vendido de dicho rubro
PROD2: Código del segundo producto más vendido de dicho rubro
CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30
días
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por cantidad de productos diferentes vendidos del rubro*/
use gd2015c1
select 
r.rubr_detalle Detalle,
sum(isnull(it.item_cantidad*it.item_precio,0)) SumaVentasEnPesos,

isnull((select top 1 item_producto 
from Item_Factura 
join Producto on item_producto = prod_codigo and prod_rubro = r.rubr_id
group by item_producto
order by sum(item_cantidad) desc
),0) Codigo1,

isnull((select top 1 item_producto from (select top 2 item_producto, sum(item_cantidad) cantidad 
from Item_Factura 
join Producto on item_producto = prod_codigo and prod_rubro = r.rubr_id
group by item_producto
order by sum(item_cantidad) desc) sub 
order by cantidad),0) Codigo2,

isnull((select top 1 fact_cliente 
from Factura 
join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero 
                    and year(fact_fecha) = '2012' and MONTH(fact_fecha) = '07'
join Producto on item_producto = prod_codigo and prod_rubro = r.rubr_id
group by fact_cliente
order by sum(item_cantidad)
),0) ClienteQueMasComproDelRubroUltimamente

from Rubro r
left join Producto p on p.prod_rubro = r.rubr_id
left join Item_Factura it on it.item_producto = p.prod_codigo

group by r.rubr_id,r.rubr_detalle

order by count(distinct p.prod_codigo) desc

--------------------------------------------------------------------------------------
select
rubr_detalle DETALLE_RUBRO,

sum(isnull(item_cantidad*item_precio,0)) VENTAS,

(select top 1 p.prod_codigo from Producto p left join Item_Factura
on p.prod_codigo=item_producto where prod_rubro=rubr_id
GROUP by p.prod_codigo
order by sum(item_cantidad) desc) PROD1,

(select top 1 prod_codigo from (select top 2 prod_codigo, sum(item_cantidad) cantidad from Producto left join Item_Factura
on prod_codigo=item_producto where prod_rubro=rubr_id
GROUP by prod_codigo
order by sum(item_cantidad) desc) as sub
order by cantidad asc) PROD2,

isnull(
    (select top 1 fact_cliente from Factura 
    join Item_Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
    join Producto on item_producto=prod_codigo 
        where prod_rubro=rubr_id and fact_fecha >= DATEADD(DAY, -30, GETDATE()) -- en vez de get date se podria elegir la fecha de la factura mas nueva
group by fact_cliente order by count(*) desc), 0) CLIENTE

from rubro
left JOIN Producto on prod_rubro=rubr_id
left join Item_Factura on item_producto=prod_codigo

group by rubr_detalle, rubr_id
order by count(distinct item_producto) desc