/*
30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.
*/

create trigger ej_30_no_permitir_mas_de_100_compras_de_1_prod_x_1_clie on Item_Factura after insert
as
BEGIN
    if exists (select 1 from inserted ins join Factura f1 on 
        ins.item_numero+ins.item_sucursal+ins.item_tipo=f1.fact_numero+f1.fact_sucursal+f1.fact_tipo
        where (
            select sum(item_cantidad) 
            from Item_Factura join Factura 
            on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
            and fact_cliente=f1.fact_cliente and month(fact_fecha)=month(f1.fact_fecha) 
            where item_producto=ins.item_producto
            ) > 100
        )
    BEGIN
        print('Se ha superado el límite máximo de compra de un producto')
        ROLLBACK TRANSACTION
    END
END