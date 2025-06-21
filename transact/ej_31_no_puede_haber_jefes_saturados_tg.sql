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

create trigger ej_31_no_puede_haber_jefes_saturados on Empleado after INSERT,UPDATE
as 
BEGIN
    declare @empleado NUMERIC(6,0)
    declare @jefe NUMERIC(6,0)
    declare @gerenteGral NUMERIC(6,0)

    set @gerenteGral = (select empl_codigo from Empleado where empl_jefe is NULL)

    declare cursor_empleados cursor FOR
    select i.empl_codigo, i.empl_jefe from inserted i

    open cursor_empleados
    FETCH next from cursor_empleados into @empleado,@jefe

    WHILE @@FETCH_STATUS = 0
    BEGIN
    IF (@jefe is not null 
        and 
        dbo.ej_11_empleados_a_cargo_recursivo(@jefe) > 20)

    UPDATE Empleado
    SET empl_jefe = isnull(
        (select empl_codigo 
        from Empleado 
        where dbo.ej_11_empleados_a_cargo_recursivo(empl_codigo) <= 19 
        and empl_codigo != @empleado),
        @gerenteGral)
    where empl_codigo = @empleado

    FETCH next from cursor_empleados into @empleado,@jefe
    END

    CLOSE cursor_empleados
    DEALLOCATE cursor_empleados

END
GO