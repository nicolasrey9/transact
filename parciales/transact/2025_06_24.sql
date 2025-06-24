/*2. Dado el contexto inflacionario se tiene que aplicar un control en el cual nunca se permita
vender un producto a un precio que no esté entre 0%-5% del precio de venta del producto
el mes anterior, ni tampoco que esté en más de un 50% el precio del mismo producto
que hace 12 meses atrás. Aquellos productos nuevos, o que no tuvieron ventas en
meses anteriores no debe considerar esta regla ya que no hay precio de referencia.*/
-------------MAL!!!!!!!---------------------------
create trigger chequeo_valores_productos on Item_Factura after insert,update
as
begin
    if (select count(*) from inserted ins
                join Factura f on ins.item_tipo+ins.item_sucursal+ins.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
                join Item_Factura it on it.item_tipo+it.item_sucursal+it.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero 
                join Factura f2 on it.item_tipo+it.item_sucursal+it.item_numero = f2.fact_tipo+f2.fact_sucursal+f2.fact_numero
                                and MONTH(f2.fact_fecha) = MONTH(f.fact_fecha) 
                                and YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
                where   ins.item_precio < it.item_precio 
                        and ins.item_precio > it.item_precio * 0.05 
                        and ins.item_precio > 1.5 * (select item_precio 
                                                    from Item_Factura 
                                                    join Factura on it.item_tipo+it.item_sucursal+it.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
                                                                and YEAR(fact_fecha) = YEAR(f.fact_fecha)-1 and MONTH(fact_fecha) = MONTH(f.fact_fecha)
                                                    where item_producto = ins.item_producto
                                                    group by item_producto)
                        and ins.item_producto in (select item_producto 
                                                    from Item_Factura
                                                    join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero 
                                                    where YEAR(fact_fecha) = YEAR(f.fact_fecha) 
                                                    and MONTH(fact_fecha) = MONTH(f.fact_fecha)-1)                            
                ) > 0
    BEGIN
    ROLLBACK TRANSACTION
    END
END
go
