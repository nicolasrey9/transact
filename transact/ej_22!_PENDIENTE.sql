/*22. Se requiere recategorizar los rubros de productos, de forma tal que nigun rubro
tenga más de 20 productos asignados, si un rubro tiene más de 20 productos
asignados se deberan distribuir en otros rubros que no tengan mas de 20
productos y si no entran se debra crear un nuevo rubro en la misma familia con
la descirpción “RUBRO REASIGNADO”, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio quede implementada.*/
create PROCEDURE ej_22_recategorizar_rubros_de_productos AS
BEGIN
declare @rubro char(4)

declare rubros_saturados CURSOR FOR
select rubr_id 
from Rubro r 
join Producto p on p.prod_rubro = r.rubr_id

group by r.rubr_id
having count(p.prod_codigo) > 20

FETCH next from rubros_saturados into @rubro

WHILE @@FETCH_STATUS = 0
BEGIN

FETCH next from rubros_saturados into @rubro
END

CLOSE rubros_saturados
DEALLOCATE rubros_saturados

END
GO