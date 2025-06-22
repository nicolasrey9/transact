/*8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene*/
select
    prod_detalle,
    max(stoc_cantidad) MaximoStock
from Producto
    join stock on prod_codigo = stoc_producto
group by
    prod_detalle
having COUNT(DISTINCT stoc_deposito) = (select count(depo_codigo) from DEPOSITO)

--Entiendo que no hay ningun articulo con stock en todos los depositos.