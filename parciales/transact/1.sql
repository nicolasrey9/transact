/*
Recalcular precios de prods con composicion
Nuevo precio: suma de precio compontentes * 0,8 
*/
Create FUNCTION precio_componentes(@producto char(8))
returns decimal(12,2)
BEGIN
    declare @precio decimal(12,2)
    set @precio=0

    declare @componente char(8)
    declare @valor_componente decimal(12,2)

    declare componentes cursor for
        select comp_componente, comp_cantidad*prod_precio from Composicion
        join Producto on comp_componente=prod_codigo
        where comp_producto=@producto
    open componentes
    fetch next from componentes into @componente, @valor_componente
    while @@FETCH_STATUS=0
    BEGIN
        set @precio+= @valor_componente + dbo.precio_componentes(@componente)
        fetch next from componentes into @componente, @valor_componente
    END
    close componentes
    DEALLOCATE componentes
    return @precio
END
GO

CREATE procedure recalcular_productos
as
BEGIN
    declare @producto char(8)

    declare prods_composicion cursor for
        select distinct comp_producto from Composicion

    open prods_composicion

    fetch next from prods_composicion into @producto
    while @@FETCH_STATUS=0
    BEGIN
        update Producto
            set prod_precio= dbo.precio_componentes(@producto) * 0.8
            where prod_codigo = @producto
        fetch next from prods_composicion into @producto
    END
    close prods_composicion
    deallocate prods_composicion
END