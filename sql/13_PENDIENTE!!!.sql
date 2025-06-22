/*13. Realizar una consulta que retorne para cada producto que posea composición nombre
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad
de los productos que lo componen. Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.*/
use gd2015c1
select 
p.prod_detalle, 
p.prod_precio

from Composicion c
join Producto p on c.comp_producto = p.prod_codigo
join Item_Factura itf on p.prod_codigo = itf.item_producto

group by p.prod_detalle, p.prod_precio

having count(c.comp_componente) > 2

order by count(c.comp_componente) desc
