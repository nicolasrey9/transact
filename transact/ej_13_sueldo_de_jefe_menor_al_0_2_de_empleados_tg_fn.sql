/*
13. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla

“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
sus empleados totales (directos + indirectos)”.

Se sabe que en la actualidad dicha regla se cumple y que 
la base de datos es accedida por n aplicaciones de
diferentes tipos y tecnologías
*/
create function sueldo_de_empleados_directos_o_indirectos(@jefe numeric(6,0))
returns decimal(12,2)
BEGIN
    declare @sueldos decimal(12,2)
    declare @subordinado numeric(6,0)
    declare @sueldo_subordinado decimal(12,2)
    
    set @sueldos = 0
    
    declare subordinados cursor FOR
        select empl_codigo, empl_salario from Empleado where empl_jefe=@jefe
    open subordinados
    fetch next from subordinados into @subordinado, @sueldo_subordinado
    while @@FETCH_STATUS=0
    BEGIN
        set @sueldos += @sueldo_subordinado + dbo.sueldo_de_empleados_directos_o_indirectos(@subordinado)
        fetch next from subordinados into @subordinado
    END
    close subordinados
    deallocate subordinados
    return @sueldos
END
GO

create trigger ej_13_sueldo_de_jefe_menor_al_0_2_de_empleados on Empleado after insert, update, DELETE
AS
BEGIN
    IF (select COUNT(*) from inserted where empl_salario < 0.2*dbo.sueldo_de_empleados_directos_o_indirectos(empl_codigo)) > 0
    BEGIN
        PRINT('Hay jefes con un sueldo mayor al 20% de la suma de sus empleados a cargo')
        ROLLBACK TRANSACTION
    END

    IF (select COUNT(*) from deleted where empl_salario < 0.2*dbo.sueldo_de_empleados_directos_o_indirectos(empl_codigo)) > 0
    BEGIN
        PRINT('Hay jefes con un sueldo mayor al 20% de la suma de sus empleados a cargo')
        ROLLBACK TRANSACTION
    END
END
GO
/*13. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla

“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
sus empleados totales (directos + indirectos)”.

Se sabe que en la actualidad dicha regla se cumple y que la base de datos es accedida por n aplicaciones de
diferentes tipos y tecnologías*/
create trigger sueldos_jefes_controlados on Empleado after INSERT, UPDATE, DELETE AS
BEGIN

    IF exists (select 1 
            from Empleado
            where empl_salario > 0.2 * dbo.sumatoriaSueldosEmpleadosACargo(empl_codigo))

    BEGIN
    ROLLBACK TRANSACTION
    END
END
GO

CREATE FUNCTION sumatoriaSueldosEmpleadosACargo_2(@empleado numeric(6,0))
returns INT
BEGIN
DECLARE @sueldos INT
DECLARE @emp NUMERIC(6,0)
DECLARE @sueldoActual INT
set @sueldos = 0
set @sueldoActual = 0

DECLARE cursor_empleados CURSOR FOR
    select empl_codigo, empl_salario from Empleado
    where empl_jefe = @empleado

open cursor_empleados

FETCH next from cursor_empleados into @emp, @sueldoActual

WHILE @@FETCH_STATUS = 0
BEGIN
    set @sueldos += @sueldoActual + dbo.sumatoriaSueldosEmpleadosACargo(@emp)

    FETCH next from cursor_empleados into @emp, @sueldoActual
END
return @sueldos
END
GO
/*
select f1.fami_id,f1.fami_detalle

from Familia f1 

where f1.fami_detalle in (select fami_detalle from Familia
                        WHERE fami_detalle = f1.fami_detalle and fami_id != f1.fami_id
                        GROUP by fami_detalle)

group by f1.fami_id,f1.fami_detalle

ORDER BY F1.fami_detalle
*/