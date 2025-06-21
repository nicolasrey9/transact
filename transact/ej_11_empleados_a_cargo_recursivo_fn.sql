/*
Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). 
Solo contar aquellos empleados (directos o indirectos) que
tengan un código mayor que su jefe directo.
*/

CREATE function ej_11_empleados_a_cargo_recursivo(@empleado numeric(6,0))
returns bigint
BEGIN
    declare @cantidad_a_cargo bigint
    declare @subordinado NUMERIC(6,0)
    set @cantidad_a_cargo=0

    DECLARE subordinados cursor for 
        select empl_codigo from Empleado WHERE empl_jefe=@empleado

    OPEN subordinados
    fetch next from subordinados into @subordinado

    while @@FETCH_STATUS=0
    BEGIN
        if @subordinado > @empleado
        BEGIN
            set @cantidad_a_cargo+=1
        END
        set @cantidad_a_cargo += dbo.ej_11_empleados_a_cargo_recursivo(@subordinado)

        fetch next from subordinados into @subordinado
    END
    close subordinados
    DEALLOCATE subordinados

    return @cantidad_a_cargo
END
GO


SELECT dbo.ej_11_empleados_a_cargo_recursivo(1)
go


select * from Empleado