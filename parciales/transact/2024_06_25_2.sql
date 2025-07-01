/*La compañia cumple años y decidió a repartir algunas sorpresas entre sus
clientes. Se pide crear el/los objetos necesarios para que se imprima un cupón
con la leyenda "Recuerde solicitar su regalo sorpresa en su próxima compra" a
los clientes que, entre los productos comprados, hayan adquirido algún producto
de los siguientes rubros: PILAS y PASTILLAS y tengan un limite crediticio menor
a $ 15000.*/
CREATE TRIGGER sorpresas_para_clientes on Item_Factura after INSERT,update AS
BEGIN
    IF exists (select 1 from inserted
                join Producto on prod_codigo = item_producto
                join Factura on fact_numero+fact_sucursal+fact_tipo=item_numero+item_sucursal+item_tipo
                join Cliente on fact_cliente = clie_codigo

                where prod_rubro in (select rubr_id from Rubro
                                    where rubr_detalle = 'PILAS' or rubr_detalle = 'PASTILLAS'
                                    group by rubr_id)
                and clie_limite_credito < '15000')
    BEGIN
    PRINT('Recuerde solicitar su regalo sorpresa en su próxima compra')
    END
END
GO