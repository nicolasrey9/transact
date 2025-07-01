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
GO

---------------------------------------------------------
/*2. Realizar un stored procedure que calcule e informe la comisión de un vendedor para un
determinado mes. Los parámetros de entrada es código de vendedor, mes y año.
El criterio para calcular la comisión es: 5% del total vendido tomando como importe base
el valor de la factura sin los impuestos del mes a comisionar, a esto se le debe sumar un
plus de 3% más en el caso de que sea el vendedor que más vendió los productos nuevos
en comparación al resto de los vendedores, es decir este plus se le aplica solo a un
vendedor y en caso de igualdad se le otorga al que posea el código de vendedor más
alto.Se considera que un producto es nuevo cuando su primera venta en la empresa se
produjo durante el mes en curso o en alguno de los 4 meses anteriores.
De no haber ventas de productos nuevos en ese periodo, ese plus nunca se aplica.*/

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
GO

/*2. Realizar un stored procedure que calcule e informe la comisión de un vendedor para un
determinado mes. Los parámetros de entrada es código de vendedor, mes y año.
El criterio para calcular la comisión es: 5% del total vendido tomando como importe base
el valor de la factura sin los impuestos del mes a comisionar, a esto se le debe sumar un
plus de 3% más en el caso de que sea el vendedor que más vendió los productos nuevos
en comparación al resto de los vendedores, es decir este plus se le aplica solo a un
vendedor y en caso de igualdad se le otorga al que posea el código de vendedor más
alto.Se considera que un producto es nuevo cuando su primera venta en la empresa se
produjo durante el mes en curso o en alguno de los 4 meses anteriores.
De no haber ventas de productos nuevos en ese periodo, ese plus nunca se aplica.*/

/* MAL!!
CREATE PROC comision_vendedor_dado_mes_y_anio @empleado numeric(6,0), @mes int, @anio int, @comision int OUTPUT AS
BEGIN
declare @porcentaje INT
set @porcentaje = 0.05

    IF (@empleado in (select top 1 empl_codigo 
                        from Empleado
                        join Factura on fact_vendedor = empl_codigo
                        join Item_Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
                        group by empl_codigo
                        order by sum(dbo.producto_es_nuevo(item_producto)) desc
                        ))
    BEGIN
    set @porcentaje +=0.03
    END
    BEGIN
    set @comision = @porcentaje * (select sum(fact_total-fact_total_impuestos) 
                                    from Factura
                                    where YEAR(fact_fecha) = @anio 
                                            and MONTH(fact_fecha) = @mes 
                                            and fact_vendedor = @empleado)
    RETURN @comision
    END
END
GO

CREATE FUNCTION producto_es_nuevo(@producto char(8))
returns INT
BEGIN
declare @respuesta INT

    if (select top 1 f1.fact_fecha
        from Factura f1
        join Item_Factura on f1.fact_sucursal+f1.fact_tipo+f1.fact_numero = item_sucursal+item_tipo+item_numero
        where item_producto = @producto 
        group by f1.fact_fecha
        order by f1.fact_fecha) in (SELECT fact_fecha from Factura
                                        where YEAR(fact_fecha) = (select max(year(fact_fecha)) from Factura)
                                        and MONTH(fact_fecha) = (select max(MONTH(fact_fecha)) from Factura)
                                        or DATEDIFF(MONTH, MONTH(fact_fecha), (select max(MONTH(fact_fecha)) from Factura)) = 4)
    BEGIN
    set @respuesta = 1
    END
    ELSE
    BEGIN
    set @respuesta = 0
    END
    RETURN @respuesta
END
GO
*/
/*2. Realizar un stored procedure que calcule e informe la comisión de un vendedor para un
determinado mes. Los parámetros de entrada es código de vendedor, mes y año.
El criterio para calcular la comisión es: 5% del total vendido tomando como importe base
el valor de la factura sin los impuestos del mes a comisionar, a esto se le debe sumar un
plus de 3% más en el caso de que sea el vendedor que más vendió los productos nuevos
en comparación al resto de los vendedores, es decir este plus se le aplica solo a un
vendedor y en caso de igualdad se le otorga al que posea el código de vendedor más
alto.Se considera que un producto es nuevo cuando su primera venta en la empresa se
produjo durante el mes en curso o en alguno de los 4 meses anteriores.
De no haber ventas de productos nuevos en ese periodo, ese plus nunca se aplica.*/

CREATE PROC comision_segun_mes_y_anio @empleado NUMERIC(6,0), @mes INT, @anio INT, @comision int OUTPUT AS
BEGIN
DECLARE @porcentaje INT
set @porcentaje = 0.05

    IF @empleado = (select top 1 fact_vendedor 
                    from Factura
                    join Item_Factura on item_tipo+item_numero+item_sucursal=fact_tipo+fact_numero+fact_sucursal
                    group by fact_vendedor
                    order by sum(dbo.producto_es_nuevo_2(item_producto,@mes,@anio)) desc)
    BEGIN
    set @porcentaje += 0.03
    END
    BEGIN
    set @comision = @porcentaje * (select sum(fact_total - fact_total_impuestos) 
                                from Factura
                                where fact_vendedor = @empleado 
                                    and YEAR(fact_fecha) = @anio
                                    and MONTH(fact_fecha) = @mes)
    RETURN @comision
    END
END
GO
create function producto_es_nuevo_2 (@producto char(8),@mes int, @anio int)
returns int
BEGIN
declare @retorno INT
    IF (select top 1 fact_fecha 
            from Factura
            join Item_Factura on item_tipo+item_numero+item_sucursal=fact_tipo+fact_numero+fact_sucursal
            where item_producto = @producto
            group by fact_fecha
            order by fact_fecha) in (select fact_fecha 
                                    from Factura
                                    where YEAR(fact_fecha) = @anio and DATEDIFF(month,fact_fecha,@mes) <= 4 -- esta mal casteado!!!
                                    group by fact_fecha)
    BEGIN
    set @retorno = 1
    END
    ELSE
    BEGIN                                    
    set @retorno = 0
    END
    return @retorno
END
GO
/*2. Realizar un stored procedure que calcule e informe la comisión de un vendedor para un
determinado mes. Los parámetros de entrada es código de vendedor, mes y año.
El criterio para calcular la comisión es: 5% del total vendido tomando como importe base
el valor de la factura sin los impuestos del mes a comisionar, a esto se le debe sumar un
plus de 3% más en el caso de que sea el vendedor que más vendió los productos nuevos
en comparación al resto de los vendedores, es decir este plus se le aplica solo a un
vendedor y en caso de igualdad se le otorga al que posea el código de vendedor más
alto.Se considera que un producto es nuevo cuando su primera venta en la empresa se
produjo durante el mes en curso o en alguno de los 4 meses anteriores.
De no haber ventas de productos nuevos en ese periodo, ese plus nunca se aplica.*/
CREATE proc comision_vendedor @vendedor NUMERIC(6,0), @mes int,@anio int AS
BEGIN
DECLARE @porcentaje INT
declare @totalVendido INT
SET @porcentaje = 0.05

IF (@vendedor = (select top 1 fact_vendedor 
                from Factura
                join Item_Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
                group by fact_vendedor
                order by sum(dbo.producto_nuevo(item_producto,@mes,@anio)) desc,fact_vendedor desc)
                )
    BEGIN
    set @porcentaje += 0.03
    END
    BEGIN
    (select @totalVendido = sum(fact_total-fact_total_impuestos) 
        from Factura 
        where fact_vendedor = @vendedor and MONTH(fact_fecha) = @mes and YEAR(fact_fecha) = @anio)
    return @totalVendido * @porcentaje 
    END

END
GO

create function producto_nuevo (@producto char(8), @mes int, @anio int)
returns int
BEGIN
    IF (select top 1 f1.fact_fecha 
        from Factura f1
        join Item_Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
        where item_producto = @producto
        group by f1.fact_fecha
        order by f1.fact_fecha) in          (select fact_fecha 
                                            from Factura
                                            where YEAR(fact_fecha) = @anio and 
                                            (MONTH(fact_fecha) = @mes 
                                            or MONTH(fact_fecha) = @mes -1
                                            or MONTH(fact_fecha) = @mes - 2 
                                            or MONTH(fact_fecha) = @mes - 3 
                                            or MONTH(fact_fecha) = @mes - 4))
    BEGIN
    RETURN 1
    END
    ELSE
    BEGIN
    RETURN 0
    END
END
GO