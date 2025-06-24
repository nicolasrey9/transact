/*24. Escriba una consulta que considerando solamente las facturas correspondientes a los
dos vendedores con mayores comisiones, retorne los productos con composición
facturados al menos en cinco facturas,
La consulta debe retornar las siguientes columnas:
 Código de Producto
 Nombre del Producto
 Unidades facturadas
El resultado deberá ser ordenado por las unidades facturadas descendente.
*/

select 
prod_codigo, 
prod_detalle, 
sum(item_cantidad) 

from Producto 
join Item_Factura on item_producto = prod_codigo
join Factura on fact_tipo+fact_numero+fact_sucursal=item_tipo+item_numero+item_sucursal and fact_vendedor in 
(select top 2 empl_codigo from Empleado group by empl_codigo, empl_comision order by empl_comision desc)
join Composicion on comp_producto = prod_codigo

group by prod_codigo, prod_detalle

having ((select count(*) from Item_Factura 
where item_producto in (select comp_producto from Composicion)
GROUP by item_producto, item_numero, item_sucursal) >= 5)


/*Realizar una consulta SQL que para cada año y familia muestre :

Año
El código de la familia más vendida en ese año.
Cantidad de Rubros que componen esa familia.
Cantidad de productos que componen directamente al producto más vendido de esa familia.
La cantidad de facturas en las cuales aparecen productos pertenecientes a esa familia.
El código de cliente que más compro productos de esa familia.
El porcentaje que representa la venta de esa familia respecto al total de venta del año.


El resultado deberá ser ordenado por el total vendido por año y familia en forma descendente.
*/

select 
(select distinct year(f1.fact_fecha)) as Año, 

(select top 1 prod_familia 
from Producto 
join Item_Factura on item_producto = prod_codigo
join Factura f2 on item_tipo+item_numero+item_sucursal = f2.fact_tipo+f2.fact_numero+f2.fact_sucursal
where year(f1.fact_fecha) = YEAR(f2.fact_fecha)
group by prod_familia
order by sum(item_cantidad) desc) as FamiliaMasVendida,

--Cantidad de Rubros que componen esa familia.
(select count(distinct prod_rubro) from Producto
where prod_familia = (select top 1 prod_familia 
from Producto 
join Item_Factura on item_producto = prod_codigo
join Factura f2 on item_tipo+item_numero+item_sucursal = f2.fact_tipo+f2.fact_numero+f2.fact_sucursal
where year(f1.fact_fecha) = YEAR(f2.fact_fecha)
group by prod_familia
order by sum(item_cantidad) desc)) as RubrosDeLaFamilia,

--Cantidad de productos que componen directamente al producto más vendido de esa familia.
(select count(comp_componente) from Producto join Composicion on comp_producto = prod_codigo
where comp_producto = (select top 1 prod_codigo from Producto where prod_familia = (select top 1 prod_familia 
from Producto 
join Item_Factura on item_producto = prod_codigo
join Factura f2 on item_tipo+item_numero+item_sucursal = f2.fact_tipo+f2.fact_numero+f2.fact_sucursal
where year(f1.fact_fecha) = YEAR(f2.fact_fecha)
group by prod_familia
order by sum(item_cantidad) desc))) as CantProductosCompDelMasVendido,

--La cantidad de facturas en las cuales aparecen productos pertenecientes a esa familia.
(select count(item_numero) 
from Factura
join Item_Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
join Producto on item_producto = prod_codigo
where prod_familia = (select top 1 prod_familia 
from Producto 
join Item_Factura on item_producto = prod_codigo
join Factura f2 on item_tipo+item_numero+item_sucursal = f2.fact_tipo+f2.fact_numero+f2.fact_sucursal
where year(f1.fact_fecha) = YEAR(f2.fact_fecha)
group by prod_familia
order by sum(item_cantidad) desc)
group by item_numero, item_producto) as CantFacturasConProductosDeFamiliaMasVendida,

--El código de cliente que más compro productos de esa familia.
(select top 1 fact_cliente 
from Factura
join Item_Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
join Producto on item_producto = prod_codigo
where prod_familia = (select top 1 prod_familia 
from Producto 
join Item_Factura on item_producto = prod_codigo
join Factura f2 on item_tipo+item_numero+item_sucursal = f2.fact_tipo+f2.fact_numero+f2.fact_sucursal
where year(f1.fact_fecha) = YEAR(f2.fact_fecha)
group by prod_familia
order by sum(item_cantidad) desc)
group by fact_cliente
order by sum(item_cantidad)) as ClienteQueMasComproDeLaFliaQueMasVendio,


--El porcentaje que representa la venta de esa familia respecto al total de venta del año.
(select sum(item_cantidad) 
from Item_Factura join Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
join Producto on prod_codigo = item_producto
where year(fact_fecha) = YEAR(f1.fact_fecha) and prod_familia = (select top 1 prod_familia 
from Producto 
join Item_Factura on item_producto = prod_codigo
join Factura f2 on item_tipo+item_numero+item_sucursal = f2.fact_tipo+f2.fact_numero+f2.fact_sucursal
where year(f1.fact_fecha) = YEAR(f2.fact_fecha)
group by prod_familia
order by sum(item_cantidad) desc))
/
(select sum(item_cantidad) 
from Item_Factura join Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
where year(fact_fecha) = YEAR(f1.fact_fecha)) as PorcentajeQueRepresentaVentasFamilia

from Factura f1
join Item_Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
join Producto on prod_codigo = item_producto
join Rubro on prod_rubro = rubr_id
join Familia on fami_id = prod_familia

group by YEAR(f1.fact_fecha), prod_familia
order by sum(item_cantidad), 2

/*26. Escriba una consulta sql que retorne un ranking de empleados devolviendo las
siguientes columnas:
 Empleado
 Depósitos que tiene a cargo
 Monto total facturado en el año corriente
 Codigo de Cliente al que mas le vendió
 Producto más vendido
 Porcentaje de la venta de ese empleado sobre el total vendido ese año.
Los datos deberan ser ordenados por venta del empleado de mayor a menor.*/

select 
empl_codigo Empleado, 

(select count(distinct depo_codigo) from DEPOSITO where depo_encargado = empl_codigo) DepositosACargo, 

sum(f1.fact_total) FacturacionEnAnioCorriente2012,

(select top 1 clie_codigo from Cliente join Factura on fact_cliente = clie_codigo and fact_vendedor = e1.empl_codigo
group by clie_codigo
order by sum(fact_total) desc) ClienteAlQueMasLeVendio,

(select top 1 item_producto 
from Item_Factura 
join Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
where fact_vendedor = empl_codigo
GROUP BY item_producto
order by sum(item_cantidad) desc) ProductoQueMasVendio,

sum(fact_total)/(select sum(fact_total) from Factura where year(fact_fecha)=2012) * 100 PorcentajeSobreTotalDelAnio

from Empleado e1
join Factura f1 on f1.fact_vendedor = e1.empl_codigo and YEAR(f1.fact_fecha) = '2012'

group by empl_codigo
order by 3 desc

/*27. Escriba una consulta sql que retorne una estadística basada en la facturacion por año y
envase devolviendo las siguientes columnas:
 Año
 Codigo de envase
 Detalle del envase
 Cantidad de productos que tienen ese envase
 Cantidad de productos facturados de ese envase
 Producto mas vendido de ese envase
 Monto total de venta de ese envase en ese año
 Porcentaje de la venta de ese envase respecto al total vendido de ese año
Los datos deberan ser ordenados por año y dentro del año por el envase con más
facturación de mayor a menor*/

select 
YEAR(f1.fact_fecha) Anio,

e1.enva_codigo CodigoDeEnvase,

e1.enva_detalle DetalleDelEnvase,

(select count(prod_codigo) from Producto where prod_envase = e1.enva_codigo) CantProductosQueTienenEseEnvase,

sum(if1.item_cantidad) CantProductosFacturadosQueTienenEseEnvase,

(select top 1 prod_codigo from Producto join Item_Factura on item_producto=prod_codigo
where prod_envase=e1.enva_codigo group by prod_codigo order by count(*) desc) ProductoMasVendidoDeEseEnvase,

sum(if1.item_cantidad * if1.item_precio) MontoTotal,

(sum(if1.item_cantidad * if1.item_precio) / (select sum(fact_total) from Factura where YEAR(fact_fecha) = YEAR(f1.fact_fecha))) * 100 Porcentaje

from Producto p1 
join Envases e1 on p1.prod_envase = e1.enva_codigo 
join Item_Factura if1 on p1.prod_codigo = if1.item_producto
join Factura f1 on if1.item_tipo+if1.item_numero+if1.item_sucursal = f1.fact_tipo+f1.fact_numero+f1.fact_sucursal

group by YEAR(fact_fecha), e1.enva_codigo,e1.enva_detalle
order by YEAR(fact_fecha), 5 DESC

/*28. Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:
 Año.
 Codigo de Vendedor
 Detalle del Vendedor
 Cantidad de facturas que realizó en ese año
 Cantidad de clientes a los cuales les vendió en ese año.
 Cantidad de productos facturados con composición en ese año
 Cantidad de productos facturados sin composicion en ese año.
 Monto total vendido por ese vendedor en ese año
Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor.*/
select

year(f1.fact_fecha) Anio,

e1.empl_codigo,

concat(e1.empl_nombre,e1.empl_apellido) Detalle,

count(f1.fact_numero) CantFacturasQueRealizoEnEseAnio,

count(DISTINCT f1.fact_cliente) CantClientesEnEseAnio,

(select count(*) 
from Producto
join Item_Factura on prod_codigo = item_producto
join Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
where prod_codigo in (select comp_producto from Composicion) and YEAR(fact_fecha) = YEAR(f1.fact_fecha) and fact_vendedor = e1.empl_codigo
) CantProdsFactConComp,

(select count(*) 
from Producto
join Item_Factura on prod_codigo = item_producto
join Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
where not prod_codigo in (select comp_producto from Composicion) and YEAR(fact_fecha) = YEAR(f1.fact_fecha) and fact_vendedor = e1.empl_codigo
)CantProdsFactSinComp,

sum(f1.fact_total) MontoTotalAnio

from Empleado e1
join Factura f1 on f1.fact_vendedor = e1.empl_codigo

group by year(f1.fact_fecha), e1.empl_codigo, e1.empl_nombre, e1.empl_apellido

order by YEAR(f1.fact_fecha), 
(select count(distinct item_producto) 
from Item_Factura 
join Factura on item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal 
where fact_vendedor = e1.empl_codigo) desc

