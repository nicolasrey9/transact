/*
Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.
*/

create FUNCTION dbo.ej_1_ocupacion_de_un_deposito(@producto char(8), @deposito char(2))
returns NVARCHAR(50)
BEGIN
    declare @retorno NVARCHAR(50)
    declare @cantidad decimal(12,2)
    declare @limite DECIMAL(12,2)

    select @cantidad=stoc_cantidad, @limite=stoc_stock_maximo from STOCK where stoc_deposito=@deposito 
    and stoc_producto=@producto 

    if @cantidad < @limite
    BEGIN
        set @retorno= concat('OCUPACION DEL DEPOSITO ', CAST(@cantidad/@limite*100 AS VARCHAR), ' %')
    END
    else
    BEGIN
        set @retorno='DEPOSITO COMPLETO'
    END

    return @retorno
END
GO

print(dbo.ej_1('00000030', '00'))
go