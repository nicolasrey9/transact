/*2. Actualmente el campo fact_vendedor representa al empleado que vendió
la factura. Implementar el/los objetos necesarios para respetar la
integridad referenciales de dicho campo suponiendo que no existe una
foreign key entre ambos.

NOTA: No se puede usar una foreign key para el ejercicio, deberá buscar
otro método*/
create TRIGGER integridad_referencial on Factura after insert, UPDATE AS
BEGIN
    if exists (select fact_vendedor from inserted
                where fact_vendedor not in (select empl_codigo from Empleado))
    BEGIN
    ROLLBACK TRANSACTION
    END
END
GO
create TRIGGER intregridad_referencial_2 on Empleado after DELETE as
BEGIN
    if exists (select empl_codigo from deleted
                where empl_codigo in (select fact_vendedor from Factura))
    BEGIN
    ROLLBACK TRANSACTION
    END
END
GO