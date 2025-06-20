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
