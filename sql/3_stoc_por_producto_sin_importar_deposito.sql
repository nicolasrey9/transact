/*3. Realizar una consulta que muestre código de producto, nombre de producto y el stock
total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
nombre del artículo de menor a mayor.*/
select 
prod_codigo CodigoProducto, 
prod_detalle NombreProducto, 
sum(stoc_cantidad) StockTotal

from Producto 
join STOCK on prod_codigo = stoc_producto
GROUP by prod_codigo, prod_detalle
order by prod_detalle