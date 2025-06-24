/*19. Cree el/los objetos de base de datos necesarios para que se cumpla la siguiente
regla de negocio automáticamente “Ningún jefe puede tener menos de 5 años de
antigüedad y tampoco puede tener más del 50% del personal a su cargo
(contando directos e indirectos) a excepción del gerente general”. Se sabe que en
la actualidad la regla se cumple y existe un único gerente general.*/
CREATE TRIGGER ej_19_jefes_experimentados_y_no_saturados on Empleado after INSERT,update
as
begin
declare @gerenteGral numeric(6,0)

set @gerenteGral = (select empl_codigo from Empleado where empl_jefe = NULL)

if exists (select 1
            from inserted i
            join Empleado e on e.empl_jefe = i.empl_codigo
            where 2012 - year(i.empl_ingreso) < 5
            ) 
OR exists (select 1 
            from Empleado
            where dbo.ej_11_empleados_a_cargo_recursivo(empl_codigo) > (select count(*)-1 from Empleado) / 2 
            and empl_codigo != @gerenteGral)

BEGIN
ROLLBACK TRANSACTION
END 

end
GO

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

go