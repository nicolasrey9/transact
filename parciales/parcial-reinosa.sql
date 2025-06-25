select YEAR(fact_fecha) anio,
clie_razon_social,
fami_id familia,
sum(item_cantidad) cantidad_unidades_compradas 
from Cliente join Factura fact on clie_codigo=fact_cliente
join Item_Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
join Producto on prod_codigo=item_producto join Familia f on prod_familia=fami_id
where clie_codigo = (
    select top 1 clie_codigo from Cliente join Factura on clie_codigo=fact_cliente
    join Item_Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
    join Producto on prod_codigo=item_producto join Familia on prod_familia=fami_id
    where fami_id=f.fami_id and YEAR(fact_fecha)=YEAR(fact.fact_fecha)
    group by clie_codigo
    order by count(distinct prod_codigo) asc, sum(item_precio*item_cantidad))
group by year(fact_fecha), fami_id, clie_codigo, clie_razon_social
order by YEAR(fact_fecha) asc, (select count(*) from Producto where prod_familia=fami_id) asc


---------------------------------------------------------


creATE function es_nuevo (@producto char(8), @mes int, @anio int)
returns bit
BEGIN
    declare @resultado bit
    set @resultado=0
    declare @fecha smalldatetime
    select top 1 @fecha=fact_fecha from Factura join Item_Factura
            on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
            where @producto=item_producto
            order by fact_fecha asc

    if year(@fecha)=@anio and (MONTH(@fecha)=@mes or MONTH(@fecha)=@mes-1 or MONTH(@fecha)=@mes-2 
        or MONTH(@fecha)=@mes-3 or MONTH(@fecha)=@mes-4)
    BEGIN
        set @resultado=1
    END

    return @resultado

END
GO

create procedure parcial @empleado numeric(6,0), @mes int, @anio int
as
BEGIN
    declare @total_vendido decimal(12,2)

    select @total_vendido=sum(fact_total-fact_total_impuestos) from Factura
    where fact_vendedor=@empleado and YEAR(fact_fecha)=@anio
    and MONTH(fact_fecha)=@mes

    if @empleado= (
        select top 1 empl_codigo from Empleado join Factura
        on fact_vendedor=empl_codigo join Item_Factura i
        on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
        where dbo.es_nuevo(item_producto, @mes, @anio) = 1
        group by empl_codigo
        order by count(item_producto) desc, empl_codigo desc
    )
    BEGIN
        print(cast(@total_vendido*0.08 as varchar(20)))
        return  
    END

    print(cast(@total_vendido*0.05 as varchar(20)))
END