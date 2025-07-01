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
/*31. Desarrolle el o los objetos de base de datos necesarios, para que un jefe no pueda
tener más de 20 empleados a cargo, directa o indirectamente, 

si esto ocurre debera asignarsele un jefe que cumpla esa condición

si no existe un jefe para asignarle se le deberá colocar como jefe al 
gerente general que es aquel que no tiene jefe.*/
create TRIGGER jefes_no_saturados on Empleado after INSERT,UPDATE AS
BEGIN
DECLARE @gerenteGral numeric(6,0)
DECLARE @codigoJefe NUMERIC(6,0)
DECLARE @empleado NUMERIC(6,0)

set @gerenteGral = (select empl_codigo 
                    from Empleado
                    where empl_jefe is null
                    group by empl_codigo)

DECLARE jefes_saturados cursor FOR
    select empl_codigo, empl_jefe from Empleado
    where dbo.cantidad_empleados_a_cargo(empl_jefe) > 20 and empl_jefe != @gerenteGral
    group by empl_codigo

open jefes_saturados

FETCH next from jefes_saturados into @empleado,@codigoJefe

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE Empleado
    set empl_jefe = isnull((select empl_codigo 
                            from Empleado
                            where dbo.empleados_a_cargo(empl_codigo) < 20 and empl_codigo != @empleado
                            group by empl_codigo),@gerenteGral)
    where empl_codigo = @empleado
    FETCH next from jefes_saturados into @empleado,@codigoJefe
END
close jefes_saturados
DEALLOCATE jefes_saturados
END
GO

create function empleados_a_cargo(@empleado numeric(6,0))
returns INT
BEGIN
declare @cantidad INT
declare @subdito NUMERIC(6,0)
set @cantidad = 0

    DECLARE emp cursor FOR
        select empl_codigo 
        from Empleado
        where empl_jefe = @empleado
        group by empl_codigo
    
open emp

FETCH next from emp into @subdito

WHILE @@FETCH_STATUS = 0
BEGIN
    set @cantidad += 1 + dbo.empleados_a_cargo(@subdito)
    FETCH next from emp into @subdito
END
close emp
DEALLOCATE emp

return @cantidad
END
GO