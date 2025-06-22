/*4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100.*/
select 
prod_codigo, 
prod_detalle, 
(select count(comp_componente) from Composicion where comp_producto = prod_codigo) CantComponentes

from Producto 
join STOCK on prod_codigo = stoc_producto

group by prod_codigo, prod_detalle

having avg(stoc_cantidad) > '100'

order by 3 desc
------------Otra opcion------------------------
select
    prod_codigo,
    prod_detalle,
    count(comp_componente) AS 'cantidad que lo compone'
from Producto
left join Composicion on prod_codigo = comp_producto
where prod_codigo in
(select stoc_producto
from STOCK
group by stoc_producto
having AVG(stoc_cantidad) > 100)
group by prod_codigo, prod_detalle
order by count(comp_componente) desc