/*
Se requiere reasignar los vendedores a los clientes. Para ello se solicita que
realice el o los objetos de base de datos necesarios para asignar a cada uno de los
clientes 

el vendedor que le corresponda, entendiendo que el vendedor que le
corresponde es aquel que 

le vendió más facturas a ese cliente, si en particular un
cliente no tiene facturas compradas se le deberá asignar el vendedor con más
venta de la empresa, o sea, el que en monto haya vendido más.
*/

create procedure ej_28_creo_que_no_funciona
as
begin
    update Cliente
        set clie_vendedor = (
            select top 1 empl_codigo from Empleado
            order by (select count(*) from Factura where fact_vendedor=empl_codigo
            and fact_cliente=clie_codigo) desc, 
            (select sum(fact_total) from Factura where fact_vendedor=empl_codigo) desc
        )
end
GO

create procedure ej_28_actualizar_vendedores_de_cleintes_update_falopa_pc
as
begin
    UPDATE C
        SET clie_vendedor = (
            SELECT TOP 1 E.empl_codigo
            FROM Empleado E
            ORDER BY 
                (SELECT COUNT(*) 
                FROM Factura F 
                WHERE F.fact_vendedor = E.empl_codigo 
                AND F.fact_cliente = C.clie_codigo) DESC,
                (SELECT SUM(F2.fact_total) 
                FROM Factura F2 
                WHERE F2.fact_vendedor = E.empl_codigo) DESC
        )
    FROM Cliente C
end
GO