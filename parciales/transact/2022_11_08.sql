/*2. Implementar una regla de negocio de validación en linea que permita
implementar una lógica de control de precios en las ventas. Se deberá
poder seleccionar una lista de rubros y aquellos productos de los rubros
que sean los seleccionados no podrán aumentar por mes más de un 2
%. En caso que no se tenga referencia del mes anterior no validar
dicha regla.*/
create TRIGGER control_precios on Item_Factura after INSERT, update AS
BEGIN
    IF exists (select 1 from inserted
                join Factura f1 on f1.fact_numero+f1.fact_sucursal+f1.fact_tipo=item_numero+item_sucursal+item_tipo
                join Producto p on item_producto = p.prod_codigo
                where p.prod_rubro in (select rubr_id from Rubro) --no se como seria lo de la lista de rubros
                group by item_producto
                having p.prod_precio >= 1.02 * (select isnull(prod_precio,p.prod_precio) 
                                            from Item_Factura 
                                            join Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
                                            join Producto on item_producto = prod_codigo
                                            where YEAR(fact_fecha) = YEAR(f1.fact_fecha) 
                                            and month(fact_fecha) = DATEADD(MONTH,-1,MONTH(F1.fact_fecha)))
                )
    BEGIN
    ROLLBACK TRANSACTION
    END

END
GO