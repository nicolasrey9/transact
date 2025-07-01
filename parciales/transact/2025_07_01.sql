/*2. Cree el o los objetos necesarios para que controlar que 

un producto no pueda tener asignado un rubro que tenga más de 20 productos asignados,

si esto ocurre, hay que asignarle el rubro que menos productos tenga
asignado e informar a que producto y que rubro se le asigno. 

En la
actualidad la regla se cumple y no se sabe la forma en que se accede a
la Base de Datos.*/
CREATE TRIGGER evitar_rubros_colapsados on Producto after INSERT,UPDATE
as
BEGIN
declare @producto char(8)
declare @nuevoRubro char(4)
declare @afectados INT
set @afectados = 0

    declare prods_fallados cursor FOR
    select prod_codigo 
        from inserted
        join Rubro on prod_rubro = rubr_id
        where dbo.cantidad_productos(prod_rubro) > 20

    open prods_fallados

    FETCH next from prods_fallados into @producto
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT TOP 1 @nuevoRubro = rubr_id 
        FROM Rubro
        ORDER BY dbo.cantidad_productos(rubr_id)

        UPDATE Producto
        set prod_rubro = @nuevoRubro
        where prod_codigo = @producto

        PRINT(concat('Producto: ',@producto,' Nuevo Rubro: ', @nuevoRubro))
        set @afectados += 1
        FETCH next from prods_fallados into @producto
    END
    close prods_fallados
    DEALLOCATE prods_fallados
    IF @afectados = 0
    BEGIN
        PRINT ('No se encontraron productos con rubros que excedan 20 productos')
    END
END
GO

create function cantidad_productos (@rubro char(4))
returns int
BEGIN
    RETURN (SELECT COUNT(*) FROM Producto WHERE prod_rubro = @rubro)
END
GO