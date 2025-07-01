/*1. Implementar una regla de negocio en linea donde se valide que nunca
un producto compuesto pueda estar compuesto por componentes de
rubros distintos a el.*/
CREATE TRIGGER composicion_productos on Composicion after INSERT,UPDATE AS
BEGIN
    if exists (SELECT prod_rubro from inserted i1
        join Producto on comp_componente = prod_codigo
        where prod_rubro not in (select prod_rubro from inserted
                                join Producto on prod_codigo = comp_producto
                                where comp_producto = i1.comp_producto))
    BEGIN
    PRINT ('Un producto compuesto nunca puede estar compuesto por componentes de rubros distintos a el')
    ROLLBACK TRANSACTION
    END
END
GO