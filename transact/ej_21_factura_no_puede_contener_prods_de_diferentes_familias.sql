/*21. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla.*/
create trigger ej_21_factura_no_puede_contener_prods_de_diferentes_familias on Item_Factura after INSERT,UPDATE
as
BEGIN
IF (select count(distinct f.fami_id) 
    from inserted i
    join Producto p on i.item_producto = p.prod_codigo
    join Familia f on f.fami_id = p.prod_familia
    group by i.item_sucursal+i.item_tipo+i.item_numero
    ) > 1
BEGIN
ROLLBACK TRANSACTION
END

END
GO