/*18. Sabiendo que el limite de credito de un cliente es el monto maximo que se le
puede facturar mensualmente, cree el/los objetos de base de datos necesarios
para que dicha regla de negocio se cumpla automaticamente. No se conoce la
forma de acceso a los datos ni el procedimiento por el cual se emiten las facturas*/
CREATE TRIGGER no_superar_limite_credito_cliente on Item_factura after INSERT,UPDATE AS
BEGIN
    IF exists (select 1
    from Factura f1
    join inserted on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
    group by fact_cliente,year(fact_fecha),MONTH(fact_fecha)
    having sum(f1.fact_total) > (select clie_limite_credito 
                                from Cliente
                                where clie_codigo = f1.fact_cliente
                                group by clie_codigo, clie_limite_credito)
    )
    BEGIN
    ROLLBACK TRANSACTION
    END

END
GO
-------------------------
CREATE TRIGGER no_superar_limite_credito_cliente_2 ON Item_factura AFTER INSERT, UPDATE AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Factura f ON i.item_tipo = f.fact_tipo 
                      AND i.item_sucursal = f.fact_sucursal 
                      AND i.item_numero = f.fact_numero
        JOIN Cliente c ON f.fact_cliente = c.clie_codigo
        GROUP BY f.fact_cliente, c.clie_limite_credito, YEAR(f.fact_fecha), MONTH(f.fact_fecha)
        HAVING SUM(f.fact_total) > c.clie_limite_credito
    )
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR('Error: El cliente ha excedido su límite de crédito mensual.', 16, 1)
    END
END
GO