/*17. Escriba una consulta que retorne una estadística de ventas por año y mes para cada
producto.
La consulta debe retornar:
PERIODO: Año y mes de la estadística con el formato YYYYMM
PROD: Código de producto
DETALLE: Detalle del producto
CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo
pero del año anterior
CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el
periodo
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por periodo y código de producto.*/
select 
concat(year(f.fact_fecha),MONTH(f.fact_fecha)) PERIODO,

p.prod_codigo CodigoProducto,

p.prod_detalle DetalleProducto,

sum(isnull(iF1.item_cantidad,0)) CantidadVendida,

(select sum(isnull(item_cantidad,0)) 
from Item_Factura 
join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero 
    and YEAR(fact_fecha) = YEAR(f.fact_fecha)-1 and MONTH(fact_fecha) = MONTH(f.fact_fecha)
    where item_producto = p.prod_codigo) CantVendidaMismoMesAnioAnterior,

count(distinct f.fact_numero) CantFacturas

from Factura f 
join Item_Factura iF1 on if1.item_tipo+if1.item_sucursal+if1.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
join Producto p on iF1.item_producto = p.prod_codigo

group by p.prod_codigo,p.prod_detalle,year(f.fact_fecha),MONTH(f.fact_fecha) 
order by YEAR(f.fact_fecha), MONTH(f.fact_fecha), p.prod_codigo

----------------------------------------------------------------------------------------------------------------------
select CAST(YEAR(f.fact_fecha) AS VARCHAR(4)) + RIGHT('00' + CAST(MONTH(f.fact_fecha) AS VARCHAR(2)), 2) + ' PROD: '
+ prod_codigo periodo, prod_detalle detalle, sum(item_cantidad) cantidad_vendida,
(select isnull(sum(item_cantidad), 0) from Item_Factura i join Factura a on
a.fact_numero+a.fact_sucursal+a.fact_tipo=i.item_numero+i.item_sucursal+i.item_tipo and YEAR(a.fact_fecha)=YEAR(f.fact_fecha)-1
and MONTH(a.fact_fecha)=MONTH(f.fact_fecha) where i.item_producto=prod_codigo) ventas_año_anterior,
count(*) cant_facturas
from Producto join Item_Factura on item_producto=prod_codigo join Factura f ON
f.fact_numero+f.fact_sucursal+f.fact_tipo=item_numero+item_sucursal+item_tipo
group by prod_codigo, prod_detalle, year(f.fact_fecha), MONTH(fact_fecha)
order by year(fact_fecha) asc, MONTH(fact_fecha) asc, prod_codigo