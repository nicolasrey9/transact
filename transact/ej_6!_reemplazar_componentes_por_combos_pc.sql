/*
Realizar un procedimiento que si en alguna factura se facturaron componentes
que conforman un combo determinado (o sea que juntos componen otro
producto de mayor nivel), en cuyo caso deberá reemplazar las filas 
correspondientes a dichos productos por una sola fila con el producto que
componen con la cantidad de dicho producto que corresponda.
*/

-- se podria mejorar para que tolere que haya mas de un valor del combo
-- ejemplo: si hay 4 B y 6 C, eso podrían ser 2 combos de A si B=2 y C=3).
-- **actualmente no tolera este ejemplo ya que, no entra en el select del cursor. Y despues inserta 1 combo** 
create procedure ej_6_reemplazar_componentes_por_combos AS
BEGIN
    declare @item_numero char(8), @sucursal char(4), @tipo char(1), @comp_producto char(8), @precio_total decimal(12,2)

    declare combos cursor for
        select item_numero, item_sucursal, item_tipo, c.comp_producto, sum(item_cantidad*item_precio) PROCESADO from Item_Factura  
            join Composicion c on c.comp_componente=item_producto AND
            item_cantidad = c.comp_cantidad
            group by item_numero, item_sucursal, item_tipo, c.comp_producto
            having count(*) = (select count(*) from Composicion c2 where c2.comp_producto=c.comp_producto)
    open combos
    fetch next from combos into @item_numero, @sucursal, @tipo, @comp_producto, @precio_total
    while @@FETCH_STATUS=0
    BEGIN
        delete from Item_Factura where item_numero=@item_numero and item_sucursal=@sucursal and item_tipo=@tipo
        and item_producto in (select comp_componente from Composicion where comp_producto=@comp_producto)

        insert Item_Factura (item_numero, item_sucursal, item_tipo, item_cantidad, item_precio, item_producto) 
        values (@item_numero, @sucursal, @tipo, 1, @precio_total, @comp_producto)
        
        fetch next from combos into @item_numero, @sucursal, @tipo, @comp_producto, @precio_total
    END
    close combos 
    deallocate combos
END
go
--Solucion Profe mega volada
/* Realizar un procedimiento que si en alguna factura se facturaron componentes
que conforman un combo determinado (o sea que juntos componen otro
producto de mayor nivel), en cuyo caso deberá reemplazar las filas 
correspondientes a dichos productos por una sola fila con el producto que
componen con la cantidad de dicho producto que corresponda.*/
CREATE PROCEDURE pr_ejercicio6 AS 
BEGIN
	DECLARE @tipo char(1), @sucursal char(4), @numero CHAR(8), @producto CHAR(8)

	DECLARE c_compuesto CURSOR FOR 
	SELECT TOP 500 c.comp_producto, i.item_tipo, i.item_sucursal, i.item_numero FROM Composicion c
	INNER JOIN Item_Factura i ON c.comp_componente = i.item_producto
	WHERE i.item_cantidad = c.comp_cantidad  
	GROUP BY c.comp_producto, i.item_tipo, i.item_sucursal, i.item_numero  
	HAVING COUNT(*) = (SELECT COUNT(*) from Composicion c2 where c.comp_producto = c2.comp_producto)

	CREATE TABLE #insert_item(
	tempo_tipo CHAR(1),
	tempo_sucursal CHAR(4),
	tempo_numero CHAR(8),
	tempo_compuesto CHAR(8)
	)
	CREATE TABLE #delete_item(
	tempo_tipo CHAR(1),
	tempo_sucursal CHAR(4),
	tempo_numero CHAR(8),
	tempo_componente CHAR(8)
	)

	WHILE EXISTS (SELECT 1 FROM Composicion c
	INNER JOIN Item_Factura i ON c.comp_componente = i.item_producto
	WHERE i.item_cantidad = c.comp_cantidad  
	GROUP BY c.comp_producto, i.item_tipo, i.item_sucursal, i.item_numero  
	HAVING COUNT(*) = (SELECT COUNT(*) from Composicion c2 where c.comp_producto = c2.comp_producto))
	BEGIN
		OPEN c_compuesto
		FETCH NEXT FROM c_compuesto INTO @producto, @tipo, @sucursal, @numero
		WHILE (@@FETCH_STATUS = 0)
		BEGIN

			INSERT INTO #insert_item VALUES (@tipo, @sucursal, @numero, @producto)
   	  
			INSERT INTO #delete_item  
			SELECT @tipo, @sucursal, @numero, comp_componente 
			FROM composicion where comp_producto = @producto

			FETCH NEXT FROM c_compuesto INTO @producto, @tipo, @sucursal, @numero
		END
		CLOSE c_compuesto
		DEALLOCATE c_compuesto

		BEGIN TRANSACTION

		insert item_factura
		SELECT tempo_tipo, tempo_sucursal, tempo_numero, tempo_compuesto,1,p.prod_precio 
		FROM #insert_item if2 INNER JOIN Producto p ON if2.tempo_compuesto = p.prod_codigo 

		delete item_factura where 
		item_tipo+item_sucursal+item_numero+item_producto IN (select 
		tempo_tipo+tempo_sucursal+tempo_numero+tempo_componente from #delete_item)

		DELETE FROM #insert_item
   	  
		DELETE FROM #delete_item  

		COMMIT TRANSACTION
	END
END
GO