/*
Realizar una función que dado un artículo y una fecha, retorne el stock que
existía a esa fecha
*/

CREATE function ej_2_stock_en_una_fecha(@producto char(8), @deposito char(2), @fecha SMALLDATETIME)
returns decimal(12,2)
BEGIN
    declare @stock decimal(12,2)
    declare @minimo decimal(12,2)
    declare @maximo decimal(12,2)
    declare @cantidad_vendida decimal(12,2)

    select @stock=stoc_cantidad, @maximo=stoc_stock_maximo, @minimo=stoc_punto_reposicion
    from STOCK where stoc_deposito=@deposito and stoc_producto=@producto 


    declare egreso_de_producto cursor for
        select item_cantidad from Item_Factura join Factura on item_numero+item_sucursal+item_tipo=
        fact_numero+fact_sucursal+fact_tipo where item_producto=@producto and fact_fecha > @fecha
        order by fact_fecha desc

    open egreso_de_producto

    fetch next from egreso_de_producto into @cantidad_vendida

    while @@FETCH_STATUS=0
    BEGIN
        set @stock += @cantidad_vendida
        if @stock > @maximo
        BEGIN
            set @stock=@minimo
        END
        fetch next from egreso_de_producto into @cantidad_vendida
    END

    close egreso_de_producto
    DEALLOCATE egreso_de_producto

    return @stock
END
GO
