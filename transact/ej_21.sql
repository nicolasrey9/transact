/*21. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla.*/
create trigger ej_22_factura_no_puede_contener_prods_de_diferentes_familias on Item_Factura after INSERT,UPDATE
as
BEGIN
END
GO