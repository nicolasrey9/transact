/*6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.*/
select 
r.rubr_id, 
r.rubr_detalle,
count(distinct p.prod_codigo),
(sum(isnull(s.stoc_cantidad,0)))

from Rubro r
left join Producto p on p.prod_rubro = r.rubr_id 
and prod_codigo in (select stoc_producto 
                from STOCK 
                group by stoc_producto 
                having (sum(isnull(stoc_cantidad,0))) > 
                                (select stoc_cantidad from STOCK where stoc_deposito = '00' and stoc_producto = '00000000'))

left join STOCK s on s.stoc_producto = p.prod_codigo

group by r.rubr_id, r.rubr_detalle