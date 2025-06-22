/*9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.*/
select empl_jefe, empl_codigo, empl_nombre, count(depo_encargado)

from Empleado
join DEPOSITO on (depo_encargado = empl_codigo or depo_encargado = empl_jefe)

group by empl_jefe, empl_codigo, empl_nombre

-------------------------------------------------------------------------
select empl_jefe, empl_codigo, empl_nombre, count(depo_codigo)

from Empleado
join DEPOSITO on (depo_encargado = empl_codigo or depo_encargado = empl_jefe)

group by empl_jefe, empl_codigo, empl_nombre
-------------------------------------------------------------------------
--VERSION PROFE:
select empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre), count(depo_codigo)
from Empleado left join DEPOSITO on empl_codigo = depo_encargado or empl_jefe = depo_encargado
group by empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre)