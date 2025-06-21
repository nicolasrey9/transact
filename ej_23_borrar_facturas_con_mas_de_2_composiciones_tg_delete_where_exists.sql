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