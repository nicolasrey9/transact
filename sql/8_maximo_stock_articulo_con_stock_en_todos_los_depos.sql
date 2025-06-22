/*8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene*/
select prod_detalle, max(stoc_cantidad)
from producto join stock on prod_codigo = stoc_producto
where stoc_cantidad > 0
group by prod_detalle 
having count(*) = (select count(*) from deposito)
--Entiendo que no hay ningun articulo con stock en todos los depositos.