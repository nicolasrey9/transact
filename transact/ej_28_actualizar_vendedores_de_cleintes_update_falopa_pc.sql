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
-----------------------------------------------------------------------------
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
-----------------------------------------------------
create procedure reasignar_vendedores_a_clientes 
as
begin
--reasignar a clientes su vendedor (clie_vendedor de Cliente)
-- el nuevo vendedor es el que mas facturas le vendio a ese cliente
-- si no tiene facturas, el vendedor que vendio mas monto
declare @cliente char(6)
declare @vendedorEstrella NUMERIC(6,0)

set @vendedorEstrella = 

(select top 1 empl_codigo 
from Empleado 
join Cliente on clie_vendedor = empl_codigo
join Factura on fact_vendedor = clie_vendedor 
group by clie_codigo
order by sum(fact_total) desc)

DECLARE cursor_clientes cursor for
    select clie_codigo from Cliente

    open cursor_clientes
    FETCH NEXT from cursor_clientes into @cliente
    while @@FETCH_STATUS=0
    BEGIN
        IF (select count(*) from Factura where fact_cliente = @cliente) = 0
        BEGIN
            UPDATE Cliente
            set clie_vendedor = @vendedorEstrella
        END

        ELSE
        
        BEGIN
            UPDATE Cliente
            set clie_vendedor = 
            (select top 1 fact_vendedor 
            from Factura 
            join Cliente on clie_codigo = @cliente
            group by fact_vendedor
            order by count(fact_numero) DESC)
        END
        
        fetch next from cursor_clientes into @cliente
    END
    
    close cursor_clientes
    
    deallocate cursor_clientes
END
go