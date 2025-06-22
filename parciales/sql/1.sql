/*
Estadistica de ventas especiales.
La factura es especial si tiene mas de 1 producto con composicion vendido.

Year, cant_fact, total_facturado_especial, porc_especiales, max_factura, monto_total_vendido
Order: cant_fact DESC, monto_total_vendido DESC
*/

select year(fact_fecha), count(*) cant_facturas,
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

