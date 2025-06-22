/*14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
debe retornar son:
Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año
Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna*/
select 
c.clie_codigo CodigoCliente,
count(distinct f.fact_numero) CantDeVecesQueCompro,
avg(f.fact_total) PromedioPorCompra,
count(distinct itf.item_producto) CantProductosDiferentes,
max(f.fact_total) MontoMayorCompra

from Cliente c
join Factura f on f.fact_cliente = c.clie_codigo and YEAR(f.fact_fecha) = '2012' --ultimo anio
join Item_Factura itf on itf.item_tipo+itf.item_sucursal+itf.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero

group by c.clie_codigo
order by 2 desc
-----------------------------------------------------------------------------
select 
fact_cliente, 
count(distinct fact_numero) as VecesQueCompro, 
avg(fact_total) as PromedioMontoPorCompra, 
count(distinct item_producto) as CantProductosDiferentes, 
max(fact_total) as MontoMayorCompra

from Factura 
join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
where year(fact_fecha) = '2012'
group by fact_cliente
order by 2 desc
