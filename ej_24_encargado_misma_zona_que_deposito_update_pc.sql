/* Se requiere recategorizar los encargados asignados a los depositos. Para ello
cree el o los objetos de bases de datos necesarios que lo resueva, teniendo en
cuenta que 

un deposito no puede tener como encargado un empleado que
pertenezca a un departamento que no sea de la misma zona que el deposito, 

si esto ocurre a dicho deposito debera asignársele el empleado con menos
depositos asignados que pertenezca a un departamento de esa zona.*/

create PROCEDURE ej_24_encargado_misma_zona_que_deposito_update
AS
BEGIN
    declare @deposito char(2)
    declare @zona char(3)

    declare depositos_fallados cursor for
        select depo_codigo, depo_zona from DEPOSITO
        where depo_zona != (select depa_zona from Empleado 
        join Departamento on empl_departamento=depa_codigo
        where empl_codigo=depo_encargado)

    open depositos_fallados
    fetch next from depositos_fallados into @deposito, @zona
    while @@FETCH_STATUS=0
    BEGIN
        UPDATE DEPOSITO
            set depo_encargado= (
                select top 1 empl_codigo from Empleado 
                join Departamento on empl_departamento=depa_codigo
                where depa_zona=@zona
                order by (select count(*) from DEPOSITO where depo_encargado=empl_codigo) asc
                ) 
            WHERE depo_codigo=@deposito
        fetch next from depositos_fallados into @deposito, @zona
    END
    close depositos_fallados
    deallocate depositos_fallados
END