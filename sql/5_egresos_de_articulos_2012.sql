/*5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.*/

select 
p1.prod_codigo, 
p1.prod_detalle,
sum(if1.item_cantidad) EgresosEn2012

from Producto p1
join Item_Factura if1 on if1.item_producto = p1.prod_codigo
join Factura f1 on if1.item_sucursal+if1.item_tipo+if1.item_numero = f1.fact_sucursal+f1.fact_tipo+f1.fact_numero

where YEAR(f1.fact_fecha) = '2012' 

group by p1.prod_codigo,p1.prod_detalle

having (sum(if1.item_cantidad) > (select sum(item_cantidad) 
                        from Item_Factura 
                        join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                        where year(fact_fecha) = '2011' and item_producto = p1.prod_codigo))

