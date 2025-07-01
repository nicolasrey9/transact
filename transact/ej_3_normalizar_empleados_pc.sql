create PROCEDURE corregir_tabla_empleados @cantidad int OUTPUT AS
BEGIN
DECLARE @gerente_general NUMERIC(6,0)

select @cantidad = COUNT(*) from Empleado
where empl_jefe is NULL

if(@cantidad > 1)
BEGIN

select top 1 @gerente_general = empl_codigo 
from Empleado
where empl_jefe is null
order by empl_salario desc, empl_ingreso

UPDATE Empleado 
set empl_jefe = @gerente_general
where empl_codigo != @gerente_general and empl_jefe is NULL

END
go
/*
Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. 

Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario.

Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.
*/

create procedure ej_3_normalizar_empleados @cantidad_sin_jefe int output
as
BEGIN
    declare @gerente_general NUMERIC(6,0), @empleado NUMERIC(6,0)
    
    declare cur cursor for
        select empl_codigo from Empleado where empl_jefe is NULL
        order by empl_salario desc, empl_ingreso ASC
    open cur

    FETCH next from cur into @gerente_general

    if @@FETCH_STATUS!=0
    BEGIN
        print('error: No hay ningun empleado como camdidato a gerente')
        RETURN
    END
    set @cantidad_sin_jefe+=1
    FETCH next from cur into @empleado
    WHILE @@FETCH_STATUS=0
    BEGIN
        UPDATE Empleado
            set empl_jefe=@gerente_general
            where empl_codigo=@empleado
        set @cantidad_sin_jefe+=1
        FETCH next from cur into @empleado
    END
    
    close cur
    DEALLOCATE cur

END
GO


declare @cantidad INT
set @cantidad=0
exec ej_3_normalizar_empleados @cantidad output
select @cantidad
go
/*
Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. 

Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario.

Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.
*/
CREATE PROCEDURE correccion_tabla_empleados @cantidad int output AS
BEGIN
DECLARE @empleado NUMERIC(6,0)
SET @cantidad = 0

DECLARE empleados_libres CURSOR FOR
    select empl_codigo from Empleado
    where empl_jefe is NULL

OPEN empleados_libres

FETCH next from empleados_libres into @empleado

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE Empleado
    set empl_jefe = (select top 1 empl_codigo 
                    from Empleado
                    WHERE empl_jefe is NULL
                    group by empl_codigo
                    having empl_codigo != @empleado
                    order by empl_salario desc, empl_ingreso
                    )
    where empl_codigo = @empleado

    SET @cantidad += 1

    FETCH NEXT from empleados_libres into @empleado
END
CLOSE empleados_libres
DEALLOCATE empleados_libres

RETURN @cantidad
END
GO

/*
Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. 

Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario.

Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.
*/
