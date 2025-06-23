/*
Estadistica de ventas especiales.
La factura es especial si tiene mas de 1 producto con composicion vendido.

Year, cant_fact, total_facturado_especial, porc_especiales, max_factura, monto_total_vendido
Order: cant_fact DESC, monto_total_vendido DESC
*/

select 
year(fact_fecha), 
count(*) cant_facturas,

    (select sum(item_precio*item_cantidad) from Item_Factura
    where item_numero+item_sucursal+item_tipo in (
    select fact_numero+fact_sucursal+fact_tipo from Factura JOIN Item_Factura
    on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
    where item_producto in (select comp_producto from Composicion)
    and year(fact_fecha)=year(F.fact_fecha)
    group by fact_numero,fact_sucursal,fact_tipo
    having count(*) > 1
    )) total_facturado_especial,

    count(*) / (select COUNT(*) FROM Factura where year(fact_fecha)=YEAR(F.fact_fecha)) porcentaje_especiales,

    max(fact_total) max_factura,

    sum(fact_total) monto_total_vendido

from Factura F
where fact_numero+fact_sucursal+fact_tipo in (
    select fact_numero+fact_sucursal+fact_tipo from Factura JOIN Item_Factura
    on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
    where item_producto in (select comp_producto from Composicion)
    group by fact_numero,fact_sucursal,fact_tipo
    having count(*) > 1
    )
group by year(fact_fecha)
ORDER BY cant_facturas DESC, monto_total_vendido DESC

/*
Estadistica de ventas especiales.
La factura es especial si tiene mas de 1 producto con composicion vendido.

Year, cant_fact, total_facturado_especial, porc_especiales, max_factura, monto_total_vendido
Order: cant_fact DESC, monto_total_vendido DESC
*/
select 
YEAR(f.fact_fecha) Anio,
count(*) CantidadFacturas,
sum(f.fact_total) TotalFacturadoEspecial,
max(f.fact_total) MaximaFactura,
sum(i.item_cantidad*i.item_precio) MontoTotalVendido

from Factura f
join Item_Factura i on i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero

where f.fact_numero in (select fact_numero 
                        from Factura 
                        join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero 
                                            and YEAR(fact_fecha) = YEAR(f.fact_fecha)
                        join Composicion on item_producto = comp_producto
                        group by fact_numero
                        having count(comp_producto) > 1
                        ) 
group by YEAR(f.fact_fecha),f.fact_numero
order by 2 desc, 5 desc


select * from Factura join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
where fact_numero = '00068711'

select * from Composicion
where comp_producto = '00001705' or comp_producto = '00001707' or comp_producto = '00001718'



