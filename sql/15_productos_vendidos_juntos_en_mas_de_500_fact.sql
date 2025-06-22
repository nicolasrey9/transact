/*15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
(en la misma factura) más de 500 veces. El resultado debe mostrar el código y
descripción de cada uno de los productos y la cantidad de veces que fueron vendidos
juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron
juntos dichos productos. Los distintos pares no deben retornarse más de una vez.
Ejemplo de lo que retornaría la consulta:
PROD1 DETALLE1 PROD2 DETALLE2 VECES
1731 MARLBORO KS 1 7 1 8 P H ILIPS MORRIS KS 5 0 7
1718 PHILIPS MORRIS KS 1 7 0 5 P H I L I P S MORRIS BOX 10 5 6 2*/

select 
uno.prod_codigo, 
uno.prod_detalle, 
otro.prod_codigo, 
otro.prod_detalle, 
count(*)

from Producto uno 
join Item_Factura unitem on item_producto=uno.prod_codigo
join Item_Factura otroitem on unitem.item_numero+unitem.item_sucursal+unitem.item_tipo=
                                otroitem.item_numero+otroitem.item_sucursal+otroitem.item_tipo
join Producto otro on otroitem.item_producto=otro.prod_codigo

WHERE uno.prod_codigo < otro.prod_codigo

group by uno.prod_codigo, uno.prod_detalle, otro.prod_codigo, otro.prod_detalle
having COUNT(*) > 500

order by 5 desc

--------------1 seg menos :)-------------------
select 
uno.prod_codigo, 
uno.prod_detalle, 
otro.prod_codigo, 
otro.prod_detalle, 
count(*)

from Producto uno 
join Item_Factura unitem on item_producto=uno.prod_codigo
join Item_Factura otroitem on unitem.item_numero+unitem.item_sucursal+unitem.item_tipo=
                                otroitem.item_numero+otroitem.item_sucursal+otroitem.item_tipo
join Producto otro on otroitem.item_producto=otro.prod_codigo

group by uno.prod_codigo, uno.prod_detalle, otro.prod_codigo, otro.prod_detalle
having COUNT(*) > 500 and uno.prod_codigo < otro.prod_codigo

order by 5 desc