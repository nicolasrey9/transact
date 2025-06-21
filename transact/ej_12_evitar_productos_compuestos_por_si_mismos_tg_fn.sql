/* Cree el/los objetos de base de datos necesarios para que nunca un producto
pueda ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnologías. No se conoce la cantidad de niveles de composición existentes.*/


create FUNCTION cantidad_compuesto_por_si_mismo(@productoInicialAComparar char(8), @productoIteracion char(8))
returns INT
BEGIN
    declare @cantidad INT
    SET @cantidad = 0

    declare @componente char(8)
    declare cur cursor for
        select comp_componente from Composicion where comp_producto=@productoIteracion
    open cur
    
    fetch next from cur into @componente
    while @@FETCH_STATUS=0
    BEGIN
        if @productoInicialAComparar=@componente
        BEGIN
            set @cantidad+=1
        END
        set @cantidad+= dbo.cantidad_compuesto_por_si_mismo(@productoInicialAComparar, @componente)
        fetch next from cur into @componente
    END

    close cur
    deallocate cur

    return @cantidad
END
GO

create TRIGGER ej_12_evitar_productos_compuestos_por_si_mismos_trigger on Composicion after INSERT, update
AS
BEGIN
    if (select sum(dbo.cantidad_compuesto_por_si_mismo(comp_producto, comp_producto)) from inserted) > 0
    BEGIN
        PRINT('Error se quiere insertar un producto compuesto directa o indirectamente por si mismo')
        ROLLBACK transaction
    END
END

