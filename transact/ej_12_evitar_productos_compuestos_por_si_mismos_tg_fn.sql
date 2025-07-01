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
GO
/* Cree el/los objetos de base de datos necesarios para que nunca un producto
pueda ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnologías. No se conoce la cantidad de niveles de composición existentes.*/
CREATE FUNCTION dbo.Ejercicio12Func(@producto CHAR(8),@Componente char(8))
RETURNS int
AS
BEGIN
	IF @producto = @Componente 
		RETURN 1
	ELSE
		BEGIN
		DECLARE @ProdAux char(8)
		DECLARE cursor_componente CURSOR FOR SELECT comp_componente
										FROM Composicion
										WHERE comp_producto = @Componente
		OPEN cursor_componente
		FETCH NEXT from cursor_componente INTO @ProdAux
		WHILE @@FETCH_STATUS = 0
			BEGIN
				IF dbo.Ejercicio12Func(@producto,@prodaux) = 1
					RETURN 1 
				FETCH NEXT from cursor_componente INTO @ProdAux
			END
		CLOSE cursor_componente
		DEALLOCATE cursor_componente
		RETURN 0
		END
RETURN 0
END
GO


CREATE TRIGGER Ejercicio12 ON COMPOSICION FOR INSERT, UPDATE  
AS 
BEGIN 
    IF (select SUM(DBO.Ejercicio12Func(COMP_PRODUCTO,COMP_COMPONENTE)) FROM INSERTED) > 0
        BEGIN
            PRINT 'UN PRODUCTO NO PUEDE ESTAR COMPUESTO POR SI MISMO'
            ROLLBACK
        END
END
GO