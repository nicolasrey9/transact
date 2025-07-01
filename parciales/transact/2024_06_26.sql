/*La compañía desea implementar una política para incrementar el consumo de
ciertos productos. Se pide crear el/los objetos necesarios para que se imprima
un cupón con la leyenda "Ud. accederá a un 5% de descuento del total de su
próxima factura" a los clientes que realicen compras superiores a los $5000 y
que entre los productos comprados haya adquirido algún producto de los
siguientes rubros:

PILAS
PASTILLAS
ARTICULOS DE TOCADOR*/
CREATE TRIGGER cupon_descuento on Item_Factura after INSERT, UPDATE as
BEGIN
    IF exists(select 1 from inserted ins
            join Factura on fact_numero+fact_sucursal+fact_tipo=ins.item_numero+ins.item_sucursal+ins.item_tipo
            where fact_total > '5000' and                      (select count(*) from Producto
                                                                JOIN Rubro on prod_rubro = rubr_id
                                                                where prod_codigo = ins.item_producto
                                                                and (rubr_detalle = 'PILAS' 
                                                                    or rubr_detalle = 'PASTILLAS' 
                                                                    or rubr_detalle = 'ARTICULOS DE TOCADOR')) >= 1)
    BEGIN
    PRINT('Ud. accederá a un 5% de descuento del total de su próxima factura')
    END
END
GO
-----------------OTRA OPCION-----------------------------
CREATE TRIGGER cupon_descuento_2 on Item_Factura after INSERT, UPDATE as
BEGIN
    IF exists(select 1 from inserted ins
            join Factura on fact_numero+fact_sucursal+fact_tipo=ins.item_numero+ins.item_sucursal+ins.item_tipo
            where fact_total > '5000' and       (select rubr_id from Rubro
                                            where rubr_detalle = 'PILAS'
                                            or rubr_detalle = 'PASTILLAS'
                                            or rubr_detalle = 'ARTICULOS DE TOCADOR'
                                            group by rubr_id) in (select prod_rubro from Producto
                                                                where prod_codigo = item_producto))
    BEGIN                                                                
    PRINT('Ud. accederá a un 5% de descuento del total de su próxima factura')
    END
END
GO