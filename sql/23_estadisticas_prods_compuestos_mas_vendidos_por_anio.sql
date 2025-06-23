/*23. Realizar una consulta SQL que para cada año muestre :
 Año
 El producto con composición más vendido para ese año.
 Cantidad de productos que componen directamente al producto más vendido
 La cantidad de facturas en las cuales aparece ese producto.
 El código de cliente que más compro ese producto.
 El porcentaje que representa la venta de ese producto respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año en forma descendente.*/
select 

year(f.fact_fecha) ANIO, 

i.item_producto COMP_MAS_VENDIDO,

(select count(comp_componente) from Composicion where comp_producto=i.item_producto) CANTIDAD_QUE_LO_COMPONE,

(select count(distinct fact_numero) 
from Item_Factura 
join Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
                and year(fact_fecha)=YEAR(f.fact_fecha) 
            where item_producto=i.item_producto) CANTIDAD_DE_FACTURAS,

(select top 1 fact_cliente 
from Factura 
join Item_Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
                    and item_producto=i.item_producto 
where year(fact_fecha)=YEAR(f.fact_fecha) 
group by fact_cliente
order by sum(item_cantidad) desc ) MAXIMO_COMPRADOR,

((select sum(item_cantidad*item_precio) 
from Item_Factura 
join Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
                and year(fact_fecha)=YEAR(f.fact_fecha) 
where item_producto=i.item_producto)
/
(select sum(fact_total) 
from Factura 
where year(fact_fecha)=YEAR(f.fact_fecha))) * 100 PORCENTAJE

from Factura f 
join Item_Factura i on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo

where i.item_producto = (
   select top 1 prod_codigo 
   from Composicion 
   join Producto on prod_codigo=comp_producto
   join Item_Factura on item_producto=prod_codigo 
   join Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
   and YEAR(fact_fecha)=year(f.fact_fecha) 
   group by prod_codigo 
   order by count(item_producto) desc
)

GROUP by year(f.fact_fecha), i.item_producto

order by sum(f.fact_total) desc
