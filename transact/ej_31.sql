/*
31. Desarrolle el o los objetos de base de datos necesarios, para que un jefe no pueda
tener más de 20 empleados a cargo, directa o indirectamente, 

si esto ocurre debera asignarsele un jefe que cumpla esa condición

si no existe un jefe para asignarle se le deberá colocar como jefe al 
gerente general que es aquel que no
tiene jefe.
*/
CREATE function cantidad_empleados_a_cargo(@empleado numeric(6,0))
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
        set @cantidad_a_cargo += 1 + dbo.cantidad_empleados_a_cargo(@subordinado)
        fetch next from subordinados into @subordinado
    END
    close subordinados
    DEALLOCATE subordinados
    return @cantidad_a_cargo
END
GO

create trigger ej_31 on Empleado after insert, UPDATE
AS
BEGIN
    declare @empleado numeric(6,0)
    declare @jefes_sobrecargados table(empl_codigo numeric(6,0))
    
    insert into @jefes_sobrecargados
        select empl_codigo from Empleado
        where (dbo.cantidad_empleados_a_cargo(empl_codigo)) > 20

    declare empleados_fallados cursor for  
        select empl_codigo
        from inserted
        where empl_jefe in (SELECT empl_codigo FROM @jefes_sobrecargados)

    open empleados_fallados
    fetch next from empleados_fallados into @empleado

    while @@fetch_status = 0
    begin
        if exists (select empl_codigo from Empleado where empl_codigo!=@empleado
            and empl_codigo not in (SELECT empl_codigo FROM @jefes_sobrecargados))
        begin
            update Empleado
            set empl_jefe = (select top 1 empl_codigo from Empleado where empl_codigo!=@empleado
                            and empl_codigo not in (SELECT empl_codigo FROM @jefes_sobrecargados))
            where empl_codigo=@empleado
        END
        ELSE
        BEGIN
            update Empleado
            set empl_jefe = (select top 1 empl_codigo from Empleado where empl_jefe is NULL and empl_codigo!=@empleado)
            where empl_codigo=@empleado
        END
        fetch next from empleados_fallados into @empleado
    end

    close empleados_fallados
    DEALLOCATE empleados_fallados
END