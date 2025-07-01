/*9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes*/
create trigger modificacion_items_compuestos on Item_Factura after INSERT,UPDATE AS

BEGIN
    select ins.item_producto 
    from inserted ins
    join Factura f on ins.item_tipo+ins.item_sucursal+ins.item_numero=f.fact_tipo+f.fact_sucursal+f.fact_numero
    where ins.item_producto in (select comp_producto from Composicion)

    
END
GO