/*
Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/

create trigger ej_26_evitar_facturas_con_productos_que_son_componentes on Item_factura after insert
AS
BEGIN
    if exists (select 1 from inserted where item_producto in (select comp_componente from Composicion))
    BEGIN
        print('Error la factura contiene un producto que es un componente de otro producto')
        ROLLBACK TRANSACTION
    END
END