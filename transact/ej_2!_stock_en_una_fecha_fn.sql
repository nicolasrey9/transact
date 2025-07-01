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
/*
Realizar una función que dado un artículo y una fecha, retorne el stock que
existía a esa fecha
*/
CREATE FUNCTION ej_2_stock_en_una_fecha(@articulo char(8), @fecha DATE)
RETURNS DECIMAL(12,2)

BEGIN


END
GO

CREATE FUNCTION fx_ejercicio_2(@producto char(8), @fecha DATE) 
RETURNS numeric(6,0) AS 
BEGIN

DECLARE @retorno numeric(6,0)
DECLARE @cantidad decimal(12,2)
DECLARE @minimo decimal(12,2)
DECLARE @maximo decimal(12,2)
DECLARE @diferencia decimal(12,2)

declare cProductos cursor for
		select I.item_cantidad 
		from factura f inner join Item_Factura i
		on f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero 
		where i.item_producto = @producto
		and f.fact_fecha >= @fecha
		order by f.fact_fecha desc

SELECT @retorno = s.stoc_cantidad, @minimo = s.stoc_punto_reposicion, 
@maximo = s.stoc_stock_maximo
FROM stock s
WHERE s.stoc_producto = @producto
AND s.stoc_deposito = '00'

SET @diferencia = @maximo - @minimo

open cProductos
fetch next from cProductos into @cantidad
while @@FETCH_STATUS = 0
begin
	set @retorno = @retorno + @cantidad
	if @retorno > @maximo
		SET @retorno = @retorno - @diferencia
	fetch next from cProductos into @cantidad
end
close cProductos;
deallocate cProductos;	

RETURN @retorno
END

GO