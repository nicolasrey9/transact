/*24. Escriba una consulta que considerando solamente las facturas correspondientes a los
dos vendedores con mayores comisiones, retorne los productos con composición
facturados al menos en cinco facturas,
La consulta debe retornar las siguientes columnas:
 Código de Producto
 Nombre del Producto
 Unidades facturadas
El resultado deberá ser ordenado por las unidades facturadas descendente.*/
select 
prod_codigo, 
prod_detalle, 
sum(item_cantidad) 

from Producto 
join Item_Factura on item_producto = prod_codigo
join Factura on fact_tipo+fact_numero+fact_sucursal=item_tipo+item_numero+item_sucursal 
    and fact_vendedor in 
            (select top 2 empl_codigo 
            from Empleado 
            group by empl_codigo, empl_comision 
            order by empl_comision desc)

where prod_codigo in (select comp_producto from Composicion)

group by prod_codigo, prod_detalle

having (select count(distinct fact_numero) from Factura
        join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
        where item_producto = prod_codigo
        GROUP by item_producto, item_numero, item_sucursal) >= 5

order by 3 DESC

