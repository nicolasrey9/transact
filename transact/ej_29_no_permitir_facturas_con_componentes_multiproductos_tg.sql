/*
29. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que 

una factura no puede contener productos que
sean componentes de diferentes productos. 

En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/

create trigger ej_29_no_permitir_facturas_con_componentes_multiproductos on Item_factura after INSERT
AS
BEGIN
    if exists (select 1 from inserted join Composicion c1 on c1.comp_componente=item_producto
        join Composicion c2 on c2.comp_componente=item_producto and c2.comp_producto != c1.comp_producto)
    BEGIN
        PRINT('Error: una factura no puede contener productos que sean componentes de diferentes productos.')
        ROLLBACK TRANSACTION
    END
END
GO

/*29. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de diferentes productos. 
En caso de que esto ocurra no debe grabarse esa factura y debe emitirse un error en pantalla.*/
create trigger ej_29_no_permitir_facturas_con_componentes_multiproductos_2 on Item_Factura after INSERT,UPDATE
AS
BEGIN
if exists (
    select 1 
    from inserted i
    join Composicion c1 on c1.comp_componente = i.item_producto
    join Composicion c2 on c2.comp_componente = i.item_producto and c1.comp_producto != c2.comp_producto
)
BEGIN
PRINT('Error: Una factura no puede contener productos que sean componentes de diferentes productos')
ROLLBACK TRANSACTION
END
END
GO
/*29. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que 

una factura no puede contener productos que sean componentes de diferentes productos. 

En caso de que esto ocurra no debe grabarse esa factura y debe emitirse un error en pantalla.*/
CREATE trigger restriccion_factura on Item_factura after INSERT, UPDATE AS
BEGIN
    if exists (select 1 from inserted
                join Composicion c1 on item_producto = c1.comp_componente
                where item_producto in (select comp_componente from Composicion c2
                                        where c2.comp_producto != c1.comp_producto))
    BEGIN
    PRINT('Error: Una factura no puede contener productos que sean componentes de diferentes productos.')
    ROLLBACK TRANSACTION
    END
END
GO