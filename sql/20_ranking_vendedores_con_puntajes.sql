/*20. Escriba una consulta sql que retorne un ranking de los mejores 3 empleados del 2012
Se debera retornar legajo, nombre y apellido, anio de ingreso, puntaje 2011, puntaje
2012. El puntaje de cada empleado se calculara de la siguiente manera: para los que
hayan vendido al menos 50 facturas el puntaje se calculara como la cantidad de facturas
que superen los 100 pesos que haya vendido en el año, para los que tengan menos de 50
facturas en el año el calculo del puntaje sera el 50% de cantidad de facturas realizadas
por sus subordinados directos en dicho año*/
select 
top 3 concat(e.empl_nombre,e.empl_apellido) NombreYApellido,
year(e.empl_ingreso) AnioDeIngreso,

case when
        (select count(distinct fact_numero+fact_sucursal+fact_tipo) from Factura where fact_vendedor = e.empl_codigo and YEAR(fact_fecha) ='2011') >= 50         
THEN(
    select count(distinct fact_numero+fact_sucursal+fact_tipo) from Factura where fact_vendedor = e.empl_codigo and fact_total > '100' and YEAR(fact_fecha) = '2011'
    )
ELSE(
    select count(distinct fact_numero+fact_sucursal+fact_tipo)/2 from Factura join Empleado sub on fact_vendedor = sub.empl_codigo and sub.empl_jefe = e.empl_codigo
    and YEAR(fact_fecha) = '2011'
    )
END Puntaje2011,

case when
        (select count(distinct fact_numero+fact_sucursal+fact_tipo) from Factura where fact_vendedor = e.empl_codigo and YEAR(fact_fecha) ='2012') >= 50         
THEN(
    select count(distinct fact_numero+fact_sucursal+fact_tipo) from Factura where fact_vendedor = e.empl_codigo and fact_total > '100' and YEAR(fact_fecha) = '2012'
    )
ELSE(
    select count(distinct fact_numero+fact_sucursal+fact_tipo)/2 from Factura join Empleado sub on fact_vendedor = sub.empl_codigo and sub.empl_jefe = e.empl_codigo
    and YEAR(fact_fecha) = '2012'
    )
END Puntaje2012

from Empleado e

group by e.empl_codigo, e.empl_nombre,e.empl_apellido, e.empl_ingreso

order by 4 desc

-------Version Nico Doc---------
select top 3 empl_codigo, empl_nombre, empl_apellido, YEAR(empl_ingreso) ANIO_INGRESO,
case when (
   select count(fact_numero) from Factura where fact_vendedor=empl_codigo
   and YEAR(fact_fecha)=2011
) >=50
then (
   select count(fact_numero) from Factura
   where fact_vendedor=empl_codigo and YEAR(fact_fecha)=2011 and fact_total>100
)
else (
   select count(fact_numero)/2 from Empleado sub join Factura on fact_vendedor=sub.empl_codigo
   where sub.empl_jefe=empl_codigo and YEAR(fact_fecha)=2011
) end PUNTAJE_2011,
case when (
   select count(fact_numero) from Factura where fact_vendedor=empl_codigo
   and YEAR(fact_fecha)=2012
) >=50
then (
   select count(fact_numero) from Factura
   where fact_vendedor=empl_codigo and YEAR(fact_fecha)=2012 and fact_total>100
)
else (
   select count(fact_numero)/2 from Empleado sub join Factura on fact_vendedor=sub.empl_codigo
   where sub.empl_jefe=empl_codigo and YEAR(fact_fecha)=2012
) end PUNTAJE_2012
from Empleado order by 6 desc