/* Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se controle que en una misma factura no puedan venderse más
de dos productos con composición. Si esto ocurre debera rechazarse la factura
*/

create trigger ej_23_borrar_facturas_con_mas_de_2_composiciones on Item_factura after INSERT
AS
BEGIN
    if (select count(*) from inserted
        where item_producto in (select comp_producto from Composicion)
        group BY item_numero, item_sucursal, item_tipo) > 2
    BEGIN
        PRINT 'HAY MÁS DE DOS PRODUCTOS CON COMPOSICIÓN EN UNA FACTURA';
        ROLLBACK TRANSACTION;
    END
END
GO

/* Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se controle que en una misma factura no puedan venderse más
de dos productos con composición. Si esto ocurre debera rechazarse la factura*/

create trigger ej_23_borrar_facturas_con_mas_de_2_composiciones_2 on Item_Factura after INSERT,UPDATE
AS
BEGIN
IF (select count(*) 
    from inserted i 
    where i.item_producto in (select comp_producto from Composicion)
    group by i.item_numero+i.item_tipo+i.item_sucursal) > 2
    
    BEGIN
    PRINT 'HAY MÁS DE DOS PRODUCTOS CON COMPOSICIÓN EN UNA FACTURA'
    ROLLBACK TRANSACTION
    END

END
go