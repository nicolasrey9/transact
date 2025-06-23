/*
Se requiere reasignar los encargados de stock de los diferentes depósitos. 
Para ello se solicita que realice el o los objetos de base de datos necesarios para

asignar a cada uno de los depósitos el encargado que le corresponda,
entendiendo que el encargado que le corresponde es 

cualquier empleado que no es jefe y que no es vendedor

o sea, que no está asignado a ningun cliente, se deberán ir asignando 
tratando de que un empleado solo tenga un deposito asignado, 

en caso de no poder se irán aumentando la cantidad de depósitos
progresivamente para cada empleado.
*/

create procedure ej_27_asignar_encargados_depositos_equitativamente_misma_cantidad
as
BEGIN
    declare @deposito char(2)
    declare depositos cursor FOR
        select depo_codigo from DEPOSITO
    open depositos
    fetch next from depositos into @deposito
    while @@FETCH_STATUS=0
    BEGIN
        update DEPOSITO
            set depo_encargado=(
                select top 1 empl_codigo
                from Empleado where empl_codigo not in (select empl_jefe from Empleado) 
                and not empl_codigo in (select clie_vendedor from Cliente)
                order by (select count(*) from DEPOSITO where depo_encargado=empl_codigo)
            )
            where depo_codigo=@deposito

        fetch next from depositos into @deposito
    END
    close depositos
    DEALLOCATE depositos
END
GO
/*27. Se requiere reasignar los encargados de stock de los diferentes depósitos. Para
ello se solicita que realice el o los objetos de base de datos necesarios para
asignar a cada uno de los depósitos el encargado que le corresponda,
entendiendo que el encargado que le corresponde es cualquier empleado que no
es jefe y que no es vendedor, o sea, que no está asignado a ningun cliente, se
deberán ir asignando tratando de que un empleado solo tenga un deposito
asignado, en caso de no poder se irán aumentando la cantidad de depósitos
progresivamente para cada empleado.*/
CREATE PROCEDURE ej_27_asignar_encargados_depositos_equitativamente_misma_cantidad_2
as
BEGIN
DECLARE @deposito char(2)

declare cursor_depositos cursor FOR
    select depo_codigo from DEPOSITO

OPEN cursor_depositos
FETCH next from cursor_depositos into @deposito

while @@FETCH_STATUS = 0
BEGIN

UPDATE DEPOSITO
set depo_encargado = 
(select top 1 empl_codigo 

from Empleado

where empl_codigo not in (
    select clie_vendedor 
    from Cliente
    group by clie_vendedor) 

and empl_codigo not in (
    select empl_jefe 
    from Empleado
    group by empl_jefe)

group by empl_codigo
order by (select count(*) from DEPOSITO where depo_encargado=empl_codigo)
)
where depo_codigo = @deposito

FETCH NEXT from cursor_depositos into @deposito
END

close cursor_depositos
DEALLOCATE cursor_depositos

END
GO