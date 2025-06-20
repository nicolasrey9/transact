/* Agregar el/los objetos necesarios para que si un cliente compra un producto
compuesto a un precio menor que la suma de los precios de sus componentes
que imprima la fecha, que cliente, que productos y a qué precio se realizó la
compra. No se deberá permitir que dicho precio sea menor a la mitad de la suma
de los componentes*/

create function precio_suma_componentes (@compuesto char(8))
returns INT
BEGIN
    declare @precio decimal(12,2)
    set @precio=0

    declare @componente char(8)
    DECLARE @cantidad decimal(12,2)

    declare cur cursor FOR
        select comp_componente, comp_cantidad from Composicion where comp_producto=@compuesto
    open cur
    fetch next from cur into @componente, @cantidad
    WHILE @@FETCH_STATUS=0
    BEGIN
        set @precio += (select prod_precio from Producto where prod_codigo=@componente) * @cantidad 
            + dbo.precio_suma_componentes(@componente)
        fetch next from cur into @componente, @cantidad
    END
    close cur
    deallocate cur

    return @precio
END
GO

create TRIGGER ej_14_no_permitir_precios_de_venta_menores_a_la_suma_de_sus_componentes on Item_factura after INSERT, UPDATE
as
BEGIN
    declare @fecha smalldatetime
    declare @cliente char(6)
    declare @producto char(8)
    declare @precio decimal(12,2)

    IF (select count(*) from inserted where item_producto in (select comp_producto from Composicion)
        and dbo.precio_suma_componentes(item_producto) * 0.5 > item_precio) > 0
    BEGIN
        print('El precio es menor a la mitad de la suma de sus componentes')
        ROLLBACK transaction
    END

    declare cur cursor for
        select fact_fecha, fact_cliente, item_producto, item_precio
        from inserted join Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo 
        where item_producto in (select comp_producto from Composicion)
        and dbo.precio_suma_componentes(item_producto) < item_precio
    
    open cur
    fetch next from cur into @fecha, @cliente, @producto, @precio

    while @@FETCH_STATUS=0
    BEGIN
        print('Se ha realizado una compra de un producto compuesto a menos del valor de la suma de los componentes' +
            'Fecha: ' + cast(@fecha as varchar)+ ' ' +
            'Cliente: ' + cast(@cliente as varchar)+ ' ' +
            'Producto Compuesto: ' + cast(@producto as varchar)+ ' ' +
            'Precio: ' + cast(@precio as varchar))
        fetch next from cur into @fecha, @cliente, @producto, @precio
    END

END