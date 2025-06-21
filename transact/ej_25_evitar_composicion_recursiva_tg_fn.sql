/*
Desarrolle el/los elementos de base de datos necesarios para que no se permita
que la composición de los productos sea recursiva, o sea, que si el producto A 
compone al producto B, dicho producto B no pueda ser compuesto por el
producto A, hoy la regla se cumple.
*/

create function tiene_composicion_cruzada(@producto_a_comparar char(8), @iterador char(8))
returns bit
BEGIN
    DECLARE @resultado BIT
    declare @composicion char(8)
    set @resultado=0

    declare composiciones cursor for
        select comp_componente from Composicion where comp_producto=@iterador
    
    open composiciones

    fetch next from composiciones into @composicion

    while @@FETCH_STATUS=0
    BEGIN
        if @producto_a_comparar = @composicion
        BEGIN
            set @resultado=1
            return @resultado
        END
        if dbo.tiene_composicion_cruzada(@producto_a_comparar, @composicion) = 1
        BEGIN
            set @resultado=1
            return @resultado
        END
        fetch next from composiciones into @composicion
    END

    close composiciones
    DEALLOCATE composiciones

    return @resultado
END
GO

create trigger ej_25_evitar_composicion_recursiva on Composicion after insert, update
as
BEGIN
    if (select count(*) from inserted where dbo.tiene_composicion_cruzada(comp_producto, comp_componente)=1) > 0
    BEGIN
        print('Hay composicion recursiva')
        ROLLBACK TRANSACTION
    END
END