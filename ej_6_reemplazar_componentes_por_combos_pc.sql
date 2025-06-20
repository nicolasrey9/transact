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