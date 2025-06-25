select 
year(f.fact_fecha) Anio,
c.clie_razon_social ClienteRazonSocial,
fam.fami_detalle Familia,
sum(isnull(it.item_cantidad,0)) CantUnidadesCompradas

from Familia fam
join Producto p on p.prod_familia = fam.fami_id
join Item_Factura it on p.prod_codigo = it.item_producto
join Factura f on it.item_tipo+it.item_sucursal+it.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
join Cliente c on c.clie_codigo = f.fact_cliente 
                   
where c.clie_codigo = 
                        (select top 1 fact_cliente 
                        from Factura 
                        join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                        join Producto on prod_codigo = item_producto and prod_familia = fam.fami_id
                        where year(fact_fecha) = YEAR(f.fact_fecha)
                        group by fact_cliente
                        order by count(distinct item_producto), sum(item_precio*item_cantidad) desc)

group by YEAR(f.fact_fecha),fam.fami_id,fam.fami_detalle,c.clie_codigo,c.clie_razon_social
order by year(f.fact_fecha),(select count(*) from Producto where prod_codigo = fam.fami_id)