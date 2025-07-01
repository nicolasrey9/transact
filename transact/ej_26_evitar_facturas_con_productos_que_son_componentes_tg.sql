/*
Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/

CREATE TRIGGER facturas_no_deben_contener_productos_compuestos on Item_Factura AFTER INSERT,UPDATE 
as
BEGIN
    IF (select count(*) from inserted i
    where i.item_producto in (select comp_componente from Composicion)) > 0
    PRINT ('ERROR: UNA FACTURA NO PUEDE CONTENER PRODUCTOS COMPONENTES')

    DELETE FROM Item_Factura
    where exists(
        select 1 
        from inserted i 
        where item_tipo+item_numero+item_sucursal = i.item_tipo+i.item_numero+i.item_sucursal 
    )

    DELETE from Factura
    where exists (
        select 1
        from inserted i 
        where fact_tipo+fact_numero+fact_sucursal = i.item_tipo+i.item_numero+i.item_sucursal
    )
END
GO

CREATE TRIGGER facturas_no_deben_contener_productos_compuestos_mas_simple on Item_Factura AFTER INSERT,UPDATE 
as
BEGIN
    IF (select count(*) from inserted i
    where i.item_producto in (select comp_componente from Composicion)) > 0
    PRINT ('ERROR: UNA FACTURA NO PUEDE CONTENER PRODUCTOS COMPONENTES')
    ROLLBACK TRANSACTION
END
GO

