CREATE PROC mayor_cantidad_dias_consecutivos_con_ventas (@producto char(8), @fecha SMALLDATETIME, @mayorCantidad int output) 
AS
BEGIN
DECLARE @fechaActual SMALLDATETIME
DECLARE @fechaAnterior SMALLDATETIME

DECLARE @cantidadActual INT

set @mayorCantidad = 0
set @cantidadActual = 0

declare fechasVentasPosteriores CURSOR FOR -- tomo las fechas posteriores o iguales a @fecha en las que hubo ventas del @producto
    select fact_fecha
    from Factura
    join Item_Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo

    where fact_fecha >= @fecha and item_producto = @producto

    group by fact_fecha
    order by fact_fecha 

OPEN fechasVentasPosteriores

FETCH NEXT from fechasVentasPosteriores INTO @fechaActual

IF @fechaActual = @fecha --en caso de que haya una venta en la fecha que se pasa como parametro 
                        --y para ya tener definida @fechaAnterior
                        --intenté evitar repetir este "chequeo" dentro del while
    BEGIN
        SET @cantidadActual = 1
        SET @mayorCantidad = 1
    END
    SET @fechaAnterior = @fecha

FETCH NEXT from fechasVentasPosteriores INTO @fechaActual --tomo una nueva fecha

WHILE @@FETCH_STATUS = 0
BEGIN
     BEGIN
        -- verifico si es consecutivo con la fecha anterior
        IF @fechaActual = dateadd(day,1,@fechaAnterior) --la fecha actual es un dia mas que la anterior
        BEGIN
            SET @cantidadActual += 1
            IF @cantidadActual > @mayorCantidad
                BEGIN
                SET @mayorCantidad = @cantidadActual
                END
        END
        ELSE
        --en caso de que no, se resetea la cantidad de dias consecutivos 'provisorios'
        BEGIN
            SET @cantidadActual = 1
        END
        
        SET @fechaAnterior = @fechaActual
    FETCH NEXT from fechasVentasPosteriores INTO @fechaActual --se va a repetir el while con una nueva fecha   
    END
END
close fechasVentasPosteriores
DEALLOCATE fechasVentasPosteriores

return @mayorCantidad --devuevo la mayor cantidad de dias consecutivos con ventas
-- otra manera: PRINT concat('La mayor cantidad de dias consecutivos con ventas de ',@producto,'a partir de: ',@fecha,' fueron: ',@mayorCantidad)
END
GO