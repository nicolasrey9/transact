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
        DELETE FROM Item_factura
        WHERE EXISTS (
            SELECT 1
            FROM inserted i2
            WHERE Item_factura.item_numero = i2.item_numero
              AND Item_factura.item_sucursal = i2.item_sucursal
              AND Item_factura.item_tipo = i2.item_tipo
        );
        DELETE FROM Factura
        WHERE EXISTS (
            SELECT 1
            FROM inserted i2
            WHERE Factura.fact_numero = i2.item_numero
              AND Factura.fact_sucursal = i2.item_sucursal
              AND Factura.fact_tipo = i2.item_tipo
        );
        ROLLBACK TRANSACTION;
    END

END