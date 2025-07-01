/*10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.*/
CREATE TRIGGER verificar_no_existencia_stock on Producto after DELETE AS
BEGIN

    if exists (select 1 from deleted del 
                join stock on del.prod_codigo = stoc_producto
                where stoc_cantidad > 0)
    BEGIN
    PRINT('No se puede eliminar un producto que tenga stock')
    ROLLBACK TRANSACTION
    END
END
GO