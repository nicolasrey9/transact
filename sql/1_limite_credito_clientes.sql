/*1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
igual a $ 1000 ordenado por código de cliente*/
use GD2015C1
select clie_codigo, clie_razon_social from Cliente
where clie_limite_credito >= '1000'
group by clie_codigo, clie_razon_social
order by clie_codigo
