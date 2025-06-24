/*20. Crear el/los objeto/s necesarios para mantener actualizadas las comisiones del
vendedor.
El cálculo de la comisión está dado por el 5% de la venta total efectuada por ese
vendedor en ese mes, más un 3% adicional en caso de que ese vendedor haya
vendido por lo menos 50 productos distintos en el mes.*/
create trigger ej_20_mantener_comisiones_updated on Factura after INSERT,UPDATE
AS
BEGIN
declare @empleado NUMERIC(6,0)
declare @porcentaje INT

declare cursor_empleados cursor FOR
    select inserted.fact_vendedor from inserted

open cursor_empleados

fetch next from cursor_empleados into @empleado

WHILE @@FETCH_STATUS = 0

BEGIN

SET @porcentaje = 0.05

if ((select count(distinct item_producto) from Item_Factura
    join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero 
            and fact_vendedor = @empleado 
            and MONTH(fact_fecha) = (select top 1 MONTH(fact_fecha) from inserted)
    ) > 50)
BEGIN
SET @porcentaje = 0.08
END

UPDATE Empleado
set empl_comision = @porcentaje * (
                    select sum(fact_total) from Factura
                    where MONTH(fact_fecha) = (select top 1 MONTH(fact_fecha) from inserted)
                    and fact_vendedor = @empleado
                    )
    where empl_codigo = @empleado

END

CLOSE cursor_empleados
DEALLOCATE cursor_empleados

END
GO