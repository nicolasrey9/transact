/*Realizar el o los objetos de base de datos necesarios para que dado un código
de producto y una fecha y devuelva la mayor cantidad de días consecutivos a
partir de esa fecha que el producto tuvo al menos la venta de una unidad en el
día, el sistema de ventas on line está habilitado 24-7 por lo que se deben evaluar
todos los días incluyendo domingos y feriados.*/
CREATE FUNCTION diasConsecutivosConVentas (@producto char(8), @fecha DATE)
RETURNs INT
BEGIN
DECLARE @fechaActual DATE
DECLARE @fechaAnterior DATE

DECLARE @mayorCantidad INT
DECLARE @cantidadActual INT

set @mayorCantidad = 0
set @cantidadActual = 0

declare fechasVentasPosteriores CURSOR FOR
    select fact_fecha
    from Factura
    join Item_Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo

    where fact_fecha >= @fecha and item_producto = @producto

    group by fact_fecha
    order by fact_fecha 

OPEN fechasVentasPosteriores

FETCH NEXT from fechasVentasPosteriores INTO @fechaActual

IF @fechaActual = @fecha
    BEGIN
        SET @cantidadActual = 1
        SET @mayorCantidad = 1
        SET @fechaAnterior = @fecha
    END

FETCH NEXT from fechasVentasPosteriores INTO @fechaActual

WHILE @@fetch_status = 0
BEGIN

     BEGIN
        -- Verificar si es consecutivo con la fecha anterior
        IF @fechaAnterior IS NOT NULL AND DATEDIFF(day, @fechaAnterior, @fechaActual) = 1
        BEGIN
            SET @cantidadActual += 1
            IF @cantidadActual > @mayorCantidad
                SET @mayorCantidad = @cantidadActual
        END
        ELSE
        BEGIN
            SET @cantidadActual = 1
        END
        
        SET @fechaAnterior = @fechaActual
    FETCH NEXT from fechasVentasPosteriores INTO @fechaActual    
    END

END
close fechasVentasPosteriores
DEALLOCATE fechasVentasPosteriores

return @mayorCantidad
END
GO