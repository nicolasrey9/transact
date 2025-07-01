create table tabla_ventas (
    codigo char(8),
    detalle char(50),
    cantMov DECIMAL(12,2),
    precioProm DECIMAL(12,2),
    ganancia DECIMAL(12,2)
)
go

CREATE procedure completar_tabla_ventas(@fecha1 DATE,@fecha2 DATE) AS
BEGIN

    insert into tabla_ventas (codigo,detalle,cantMov,precioProm,ganancia)
    select 
    p.prod_codigo, 
    p.prod_detalle, 
    count(item_tipo+item_sucursal+item_numero+item_producto),
    avg(item_precio*item_cantidad),
    (item_precio - (select avg(item_precio) 
                    from Item_Factura 
                    join Factura on item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
                    where item_producto = p.prod_codigo
                    group by item_producto, fact_fecha, item_precio
                    having fact_fecha = max(fact_fecha)))

    from Factura f
    join Item_Factura on item_tipo+item_sucursal+item_numero=f.fact_tipo+f.fact_sucursal+f.fact_numero
    join Producto p on item_producto = p.prod_codigo

    --where fact_fecha < @fecha2 and fact_fecha > @fecha1

    group by p.prod_codigo, p.prod_detalle, item_precio

END
GO