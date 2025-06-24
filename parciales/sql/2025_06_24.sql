/*1. Realizar una consulta SQL que retorne para el último año, los 5 vendedores con menos
clientes asignados, que más vendieron en pesos (si hay varios con menos clientes
asignados debe traer el que más vendió), solo deben considerarse las facturas que
tengan más de dos ítems facturados:
1) Apellido y Nombre del Vendedor.
2) Total de unidades de Producto Vendidas.
3) Monto promedio de venta por factura.
4) Monto total de ventas.
El resultado deberá mostrar ordenado la cantidad de ventas descendente, en caso de
igualdad de cantidades, ordenar por código de vendedor.
NOTA: No se permite el uso de sub-selects en el FROM.*/
select
concat(e.empl_apellido,e.empl_nombre) ApellidoYNombre,
sum(it.item_cantidad) UnidadesVendidas,
(select avg(fact_total) from Factura
where fact_vendedor = e.empl_codigo and year(fact_fecha) = (select max(year(fact_fecha)) from Factura)) MontoPromedioPorFactura,
sum(it.item_precio * it.item_cantidad) MontoTotalVentas

from Cliente c
join Factura f on f.fact_cliente = c.clie_codigo and YEAR(f.fact_fecha) = (select max(year(fact_fecha)) from Factura)
join Item_Factura it on it.item_tipo+it.item_sucursal+it.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
join Empleado e on c.clie_vendedor = e.empl_codigo

where e.empl_codigo in (select top 5 fact_vendedor from Factura
                        where year(fact_fecha) = (select max(year(fact_fecha)) from Factura)
                        group by fact_vendedor
                        order by count(distinct fact_cliente), sum(fact_total) desc)
    and f.fact_numero+f.fact_sucursal+f.fact_tipo in (
        select fact_numero+fact_sucursal+fact_tipo from Factura
        join Item_Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
        group by fact_numero, fact_sucursal, fact_tipo
        having count(*) > 2
    )
group by e.empl_codigo, e.empl_apellido,e.empl_nombre

order by 2 desc, e.empl_codigo