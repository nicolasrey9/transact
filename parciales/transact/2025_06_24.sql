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
-----------------------------------------------------------------------------------
CREATE TRIGGER unTrigger ON Item_Factura
FOR insert
AS BEGIN
    DECLARE @PROD char(6), @FECHA SMALLDATETIME, @PRECIO decimal(12,2), 
	@SUCURSAL char(4), @NUM char(8), @TIPO char(1)
    DECLARE c1 CURSOR FOR
	select fact_numero, fact_sucursal, fact_tipo from inserted 
	join Factura on fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo

	OPEN c1
	FETCH NEXT FROM c1 INTO  @NUM, @SUCURSAL ,@TIPO

	WHILE @@FETCH_STATUS = 0
	BEGIN


	    DECLARE c2 CURSOR FOR 
		select item_producto, fact_fecha, item_precio from inserted
		join Factura on fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
		where fact_numero+fact_sucursal+fact_tipo = @NUM + @SUCURSAL + @TIPO

		OPEN c2
		FETCH NEXT FROM c2 INTO @PROD, @FECHA, @PRECIO

		WHILE @@FETCH_STATUS = 0
		BEGIN


		      IF EXISTS(select 1 from Item_Factura where item_producto = @PROD 
			  and item_numero+item_sucursal+item_tipo <> @NUM+@SUCURSAL+@TIPO)
			  BEGIN 
			        IF EXISTS( select 1 from Item_Factura 
		            join Factura on fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
		            where item_producto = @PROD and DATEDIFF(MONTH, @FECHA, fact_fecha) = 1 and @PRECIO > item_precio * 1.05)
	                BEGIN 
		               Delete Item_Factura
			           where item_numero = @NUM and item_sucursal = @SUCURSAL and item_tipo = @TIPO

			           Delete Factura
			           where fact_numero = @NUM and fact_sucursal = @SUCURSAL and fact_tipo = @TIPO

				    CLOSE c2
				    DEALLOCATE c2
			        END

			       IF EXISTS( select 1 from Item_Factura 
		           join Factura on fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
		           where item_producto = @PROD and DATEDIFF(YEAR, @FECHA, fact_fecha) = 1 and @PRECIO > item_precio * 1.5)
	               BEGIN 
		              Delete Item_Factura
			          where item_numero = @NUM and item_sucursal = @SUCURSAL and item_tipo = @TIPO

			          Delete Factura
			          where fact_numero = @NUM and fact_sucursal = @SUCURSAL and fact_tipo = @TIPO

				   CLOSE c2
				   DEALLOCATE c2
			       END
			  END

		      FETCH NEXT FROM c2 INTO @PROD, @FECHA, @PRECIO
		END
		
	    FETCH NEXT FROM c1 INTO @PROD, @FECHA, @PRECIO, @NUM, @SUCURSAL ,@TIPO   
	END

	CLOSE c1
	DEALLOCATE c1
END
GO


------------ NICO ------------------

create function precio_de_mes(@producto char(8), @mes int, @anio int)
returns decimal(12,2)
BEGIN
    DECLARE @valor decimal(12,2)

    select @valor=avg(item_precio) from Item_Factura
    join Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
    where item_producto=@producto and year(fact_fecha)=@anio and month(fact_fecha)=@mes

    return @valor
END
GO

create trigger triggr on Item_Factura after insert
as
begin
    if exists (select 1 from inserted join Factura
    on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
    where
    dbo.precio_de_mes(item_producto, MONTH(fact_fecha)-1, YEAR(fact_fecha)) is not null and
    abs(item_precio - dbo.precio_de_mes(item_producto, MONTH(fact_fecha)-1, YEAR(fact_fecha))) 
    > dbo.precio_de_mes(item_producto,MONTH(fact_fecha)-1, YEAR(fact_fecha)) * 0.05)
    or 
    exists (select 1 from inserted join Factura
    on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
    where 
    dbo.precio_de_mes(item_producto, MONTH(fact_fecha), YEAR(fact_fecha)-1) is not null and
    abs(item_precio - dbo.precio_de_mes(item_producto, MONTH(fact_fecha), YEAR(fact_fecha)-1)) 
    > dbo.precio_de_mes(item_producto,MONTH(fact_fecha), YEAR(fact_fecha)-1) * 0.5)
    BEGIN
        ROLLBACK TRANSACTION
    END
END