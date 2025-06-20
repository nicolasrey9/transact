/*
Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año.
*/

create procedure ej_4_actualizar_comisiones_empleados (@empleado_que_mas_vendio NUMERIC(6,0) output) AS
BEGIN
    declare @ultimo_anio INT
    SELECT @ultimo_anio = MAX(YEAR(fact_fecha)) FROM Factura;

    select top 1 @empleado_que_mas_vendio=fact_vendedor from Factura where year(fact_fecha)=@ultimo_anio

    group by fact_vendedor ORDER by sum(fact_total) desc

    UPDATE Empleado
        set empl_comision=(select isnull(sum(fact_total),0) from Factura 
        where fact_vendedor=empl_codigo and year(fact_fecha)=@ultimo_anio)

END
GO