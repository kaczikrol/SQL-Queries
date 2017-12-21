use [Northwind]
go 


/*Wyznacz macierz quasi-korelacji produktów na podstawie tabeli Order Details. Najproœciej rzecz ujmuj¹c chodzi o to, aby wskazaæ
produkt A oraz produkt B ile razy pojawi³y siê na tym samym Orderze. Inspiracja do zadania na podstawie ksi¹zki A.Pelikant*/

--1. Tworze iloczyn kartezjañski
--2. Ogrniczam zbiór tylko do tych Orderów w których na jednej fakturze pojawi³o siê wiecej ni¿ 1 produkt
--3. Nalezy wyeliminowac duplikaty tj. ORDER XXX, PRODUCT A, PRODUCT B vs. ORDER XXX, PRODUCT B, PRODUCT A
with SET1 AS  (
select 
	O1.OrderID AS OrderID1,
	O1.ProductID AS ProductID1,
	O2.OrderID AS OrderID2, 
	O2.ProductID AS ProductID2
from [Order Details] as O1 
cross join [Order Details] as O2 
where 
O1.OrderID=O2.OrderID 
and 
O1.ProductID<>O2.ProductID
and
O1.ProductID>O2.ProductID
)

select 
	ProductID1,
	ProductID2,
	COUNT(OrderID1) as Bucket
from SET1
group by
	ProductID1,
	ProductID2
order by Bucket desc
