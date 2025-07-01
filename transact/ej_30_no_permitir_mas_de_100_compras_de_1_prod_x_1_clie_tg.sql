/*
30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.
*/
--correcta, el resto no se
create trigger ej_30_no_permitir_mas_de_100_compras_de_1_prod_x_1_clie on Item_Factura after insert
as
BEGIN
    if exists (select 1 from inserted ins join Factura f1 on 
        ins.item_numero+ins.item_sucursal+ins.item_tipo=f1.fact_numero+f1.fact_sucursal+f1.fact_tipo
        where (
            select sum(item_cantidad) 
            from Item_Factura join Factura 
            on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
                and fact_cliente=f1.fact_cliente 
                and month(fact_fecha)=month(f1.fact_fecha) 
                and YEAR(fact_fecha) = YEAR(f1.fact_fecha)
            where item_producto=ins.item_producto
            ) > 100
        )
    BEGIN
        print('Se ha superado el límite máximo de compra de un producto')
        ROLLBACK TRANSACTION
    END
END
go
/*
30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.
*/
--Note que en la primera version el where "siempre da false" porque en la tabla original 
--nunca va a haber mas de 100 productos en un mes, tenes que sumarle los que se insertan para que
--te pueda llegar a dar 100
create trigger ej30_no_mas_de_100_prods_iguales_en_un_mes on Item_Factura after insert,UPDATE
as
IF exists (
    select 1 from inserted ins
    join Factura f1 on ins.item_numero+ins.item_sucursal+ins.item_tipo=f1.fact_numero+f1.fact_sucursal+f1.fact_tipo
    join Item_Factura it on it.item_producto = ins.item_producto
    join Factura f2 on it.item_numero+it.item_sucursal+it.item_tipo=f2.fact_numero+f2.fact_sucursal+f2.fact_tipo
                and YEAR(f2.fact_fecha) = YEAR(f1.fact_fecha) 
                and MONTH(f2.fact_fecha) = MONTH(f1.fact_fecha)
                and f2.fact_cliente = f1.fact_cliente
    group by ins.item_producto, f1.fact_fecha, f1.fact_cliente
    having sum(ins.item_cantidad + it.item_cantidad) > 100
)
    BEGIN
    PRINT('Se ha superado el límite máximo de compra de un producto')
    ROLLBACK TRANSACTION
    END    
go
/*30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.*/
CREATE trigger no_mas_de_100_prods_iguales_en_un_mes on Item_Factura after INSERT,UPDATE AS
BEGIN
    IF exists (select 1 
        from Item_Factura 
        join Factura on item_numero+item_sucursal+item_tipo = fact_numero+fact_sucursal+fact_tipo
        group by fact_cliente,item_producto, year(fact_fecha),MONTH(fact_fecha)
        having sum(item_cantidad) > 100)
    BEGIN
    PRINT('Se ha superado el límite máximo de compra de un producto')
    ROLLBACK TRANSACTION 
    END
END
GO