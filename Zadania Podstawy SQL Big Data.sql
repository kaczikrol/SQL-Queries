use [Northwind]
GO

--Zadanie 1.
--Korzystaj�c z tabeli Products oraz Categories wy�wietl nazw� produktu (Products.ProductName) oraz nazw� kategorii (Categories.CategoryName), do kt�rej nale�y produkt�w.
SELECT 
P.ProductName,
C.CategoryName
from Products P
left join Categories C on C.CategoryID=P.CategoryID
order by P.ProductName

--Zadanie 2. (*)
--Korzystaj�c z tabeli Suppliers, rozbuduj poprzednie tak, aby r�wnie� zaprezentowa� nazw� dostawcy danego produktu (CompanyName) � kolumn� nazwij SupplierName.
--Wynik posortuj malej�co po cenie jednostkowej produktu.

SELECT 
P.ProductName,
C.CategoryName,
S.CompanyName
from Products P
left join Categories C on C.CategoryID=P.CategoryID
left join Suppliers S on P.SupplierID=S.SupplierID
order by P.UnitPrice desc

/*Zadanie 3.
Korzystaj�c z tabeli Products wy�wietl nazwy produkt�w (ProductName) z najwy�sz� cen� jednostkow� w danej kategorii (UnitPrice).
Wynik posortuj po nazwie produktu (rosn�co).*/

with MaxPrice_CTE (CategoryID,maxUnitPrice,CategoryName)
as 
(
	select 
	P.CategoryID, 
	max(P.UnitPrice),
	C.CategoryName
	from Products P
	left join Categories C on C.CategoryID=P.CategoryID
	group by P.CategoryID, C.CategoryName
)

select 
P.ProductName,
M.CategoryName,
P.UnitPrice
from Products P
left join MaxPrice_CTE as M on P.CategoryID=M.CategoryID
where P.UnitPrice=M.maxUnitPrice
order by P.ProductName asc

/*Zadanie 4.
Korzystaj�c z tabeli Products wy�wietl nazwy produkt�w, kt�rych cena jednostkowa jest wi�ksza ni� wszystkie �rednie ceny produkt�w wyliczone dla pozosta�ych kategorii 
(innych ni� ta, do kt�rej nale�y dany produkt. Wynik posortuj po cenie jednostkowej (malej�co).*/

--PRAWDOPODOBNIE NIEPOPRAWNy WYNIK NA SCREENIE?? --NIEWIADOMO, MY�LE ZE MOJE ROZWI�ZANIE JEST POPRWNE

with CategoriesAverage(ProductID,AVGOtherCategories)
as
(
	select 
	P1.ProductID, 
	avg(P2.UnitPrice)
	from Products P1
	left join Products P2 on P1.ProductID!=P2.ProductID
	where 
	P1.CategoryID!=P2.CategoryID
	group by
	P1.ProductID
)

select 
P.ProductName,
P.UnitPrice,
P.CategoryID,
A.AVGOtherCategories
from Products P
left join CategoriesAverage A on P.ProductID=A.ProductID
where
P.UnitPrice>A.AVGOtherCategories
order by 
P.UnitPrice desc

SELECT
AVG(UnitPrice)
from Products
where 
CategoryID!='6'

/*Zadanie 5. (*)
Korzystaj�c z tabeli Order Details, rozbuduj poprzednie zapytanie, tak, aby wy�wietli� r�wnie� maksymaln� liczb� zam�wionych sztuk (Quantity) danego produktu w jednym zam�wieniu (w danym OrderID).*/

with CategoriesAverage(ProductID,AVGOtherCategories)
as
(
	select 
	P1.ProductID, 
	avg(P2.UnitPrice)
	from Products P1
	left join Products P2 on P1.ProductID!=P2.ProductID
	where 
	P1.CategoryID!=P2.CategoryID
	group by
	P1.ProductID
)

select 
P.ProductName,
P.UnitPrice,
P.CategoryID,
A.AVGOtherCategories,
max(O.Quantity) as MaxQuantityPerOrder
from Products P
left join CategoriesAverage A on P.ProductID=A.ProductID
left join [Order Details] O on O.ProductID=P.ProductID
where
P.UnitPrice>A.AVGOtherCategories
group by
P.ProductName,
P.UnitPrice,
P.CategoryID,
A.AVGOtherCategories
order by 
P.UnitPrice desc

/*Zadanie 6.
Korzystaj�c z tabel Products oraz Order Details wy�wietl identyfikatory kategorii (CategoryID) oraz sum� wszystkie warto�ci zam�wie� produkt�w w danego kategorii 
([Order Details].UnitPrice * [Order Details].Quantitiy) bez uwzgl�dnienia zni�ki. Wynik powinien zawiera� jedynie te kategorie, dla kt�rych ww. suma jest wi�ksza ni� 200 000.
Wynik posortuj sumie warto�ci zam�wie�.*/

select
P.CategoryID,
sum(O.UnitPrice*O.Quantity) as ValueOrders
from Products P
left join [Order Details] O on O.ProductID=P.ProductID
group by
P.CategoryID
having sum(O.UnitPrice*O.Quantity)>'200000'
order by
ValueOrders desc

/*Zadanie 7. (*)
Korzystaj�c z tabeli Categories, zaktualizuj poprzednie zapytanie tak, aby zwr�ci�o opr�cz identyfikatora kategorii r�wnie� jej nazw�.*/

select
P.CategoryID,
C.CategoryName,
sum(O.UnitPrice*O.Quantity) as ValueOrders
from Products P
left join [Order Details] O on O.ProductID=P.ProductID
left join Categories C on C.CategoryID=P.CategoryID
group by
P.CategoryID,
C.CategoryName
having sum(O.UnitPrice*O.Quantity)>'200000'
order by
ValueOrders desc


/*4
Zadanie 8.
Korzystaj�c z tabel Orders oraz Employees wy�wietl liczb� zam�wie�, kt�re zosta�y wys�ane (ShipRegion) do innych region�w ni� te, w zam�wieniach obs�u�onych przez pracownika Robert King 
(FirstName -> Robert; LastName -> King).*/

with RobertKingShipRegions(ShipRegion)
as
(
	select distinct O.ShipRegion
	from Orders O
	join Employees E on O.EmployeeID=E.EmployeeID
	where 
	E.FirstName='Robert'
	and
	E.LastName='King'
	and
	O.ShipRegion is not null
)

select 
count(O.OrderID) as Orders
from Orders O
left join RobertKingShipRegions R on R.ShipRegion=O.ShipRegion 
where R.ShipRegion is null


/*Zadanie 9.
Korzystaj�c z tabeli Orders wy�wietl wszystkie kraje wysy�ki (ShipCountry), dla kt�rych wyst�puj� rekordy (zam�wienia), kt�re maj� wype�nion� warto�� w polu ShipRegion jak i rekordy z warto�ci� NULL.*/
-- Brzmi nie po polsku

/*Zadanie 10.
Korzystaj�c z odpowiednich tabel wy�wietl identyfikator produktu (Products.ProductID), nazw� produktu (Products.ProductName), kraj i miasto dostawcy 
(Suppliers.Country, Suppliers.City � nazwij je odpowiednio: SupplierCountry oraz SupplierCity) oraz kraj i miasto dostawy danego produktu (Orders.ShipCountry, Orders.ShipCity). 
Wynik ogranicz do takich produkt�w, kt�re zosta�y wys�ane cho� raz do tego samego kraju, z kt�rego pochodzi ich dostawca. Dodatkowo wynik rozszerz o informacj� czy opr�cz kraju 
zgadza si� r�wnie� region dostawcy produktu z regionem jego wys�ania � kolumn� nazwij FullMatch, kt�ra przyjmie warto�ci Y/N.
Wynik posortuj tak, aby jakby pierwsze zosta�y wy�wietlone posortowane alfabetycznie produkty, dla kt�rych zachodzi pe�na zgodno��.*/

select distinct
p.ProductID,
P.ProductName,
S.Country as SupplierCountry,
S.City as SupplierCity,
O.ShipCountry as OrdersCountry,
O.ShipCity as OrdersCity,
case S.City 
	when O.ShipCity then 'Y' 
	else 'N' 
end as FullMatch
from Products P
left join Suppliers S on P.SupplierID=S.SupplierID
left join [Order Details] OD on OD.ProductID=P.ProductID
left join Orders O on OD.OrderID=O.OrderID
where 
S.Country=O.ShipCountry
order by
FullMatch desc,
P.ProductName asc

/*Zadanie 11. (*)
Rozbuduj poprzednie zapytanie tak, aby wzi�� pod uwag� r�wnie� region, z kt�rego pochodzi dostawy jak i region wysy�ki. Kolumna FullMatch powinna posiada� nast�puj�cy zbi�r warto�ci:
� Y � dla pe�nej zgodno�ci trzech warto�ci
� N (the region doesn't match) � dla zgodno�ci kraju i miasta, ale nie regionu
� N � dla braku zgodno�ci
Do wyniku dodaj r�wnie� pola zawieraj�ce region: Suppliers.Region (nazwij je SupplierRegion) oraz Orders.ShipRegion)*/

select distinct
p.ProductID,
P.ProductName,
S.Country as SupplierCountry,
S.City as SupplierCity,
S.Region as SupplierRegion,
O.ShipCountry as OrdersCountry,
O.ShipCity as OrdersCity,
O.ShipRegion as ShipRegion,
case  
	when	(S.Country=O.ShipCountry
			and 
			S.City=O.ShipCity
			and
			(S.Region=O.ShipRegion or S.Region is null and O.ShipRegion is null)) then 'Y'
	when	(S.Country=O.ShipCountry
			and 
			S.City=O.ShipCity) then 'N (the region doesnt match)' 
	else 'N' end as FullMatch
from Products P
left join Suppliers S on P.SupplierID=S.SupplierID
left join [Order Details] OD on OD.ProductID=P.ProductID
left join Orders O on OD.OrderID=O.OrderID
where 
S.Country=O.ShipCountry
order by
FullMatch desc,
P.ProductName asc

/*Zadanie 12.
Korzystaj�c z tabeli Products zweryfikuj, czy istniej� dwa (lub wi�cej) produkty o tej samej nazwie. Zapytanie powinno zwr�ci� w kolumnie DuplicatedProductsFlag warto�� Yes lub No:*/

select distinct
case when
	P1.ProductID<>P2.ProductID then 'Yes'
	else 'No' end as DuplicatedProductsFlag
from Products P1
left join Products P2 on P1.ProductName=P2.ProductName


/*Zadanie 13.
Korzystaj�c z tabel Products oraz Order Details wy�wietl nazwy produkt�w wraz z informacj� na ilu zam�wieniach pojawi�y si� dane produkty.
Wynik posortuj tak, aby w pierwszej kolejno�ci pojawi�y si� produkty, kt�re najcz�ciej pojawiaj� si� na zam�wieniach.*/


with NumberOfOrders (ProductID, Orders) 
as 
(
	select 
	P.ProductID,
	count(distinct O.OrderID) as Orders
	from Products P 
	left join [Order Details] O on P.ProductID=O.ProductID
	group by
	P.ProductID
)

select 
P.ProductName,
N.Orders as NumberOfOrders,
sum(P.UnitPrice*N.Orders) as TotalValue
from Products P
left join NumberOfOrders N on N.ProductID=P.ProductID
group by
P.ProductName,
N.Orders
order by
N.Orders desc

/*Zadanie 14. (*)
Korzystaj�c z tabeli Orders rozbuduj poprzednie zapytanie tak, aby powy�sz� analiz� zaprezentowa� w kontek�cie poszczeg�lnych lat (Orders.OrderDate) � kolumn� nazwij OrderYear.
Tym razem wynik posortuj, tak, aby w pierwszej kolejno�ci wy�wietli� produkty najcz�ciej pojawiaj�ce si� na zam�wieniach w kontek�cie danego roku, czyli w pierwszej kolejno�ci 
interesuje nas rok: 1996, p�niej 1997 itd.*/

with NumberOfOrders (ProductID, Orders, OrderYear) 
as 
(
	select 
	P.ProductID,
	count(distinct O.OrderID) as Orders,
	year(O1.OrderDate) as OrderYear
	from Products P 
	left join [Order Details] O on P.ProductID=O.ProductID
	left join Orders O1 on O1.OrderID=O.OrderID
	group by 
	P.ProductID,
	year(O1.OrderDate)
)

select 
N.OrderYear,
P.ProductName,
N.Orders as NumberOfOrders,
sum(P.UnitPrice*N.Orders) as TotalValue
from Products P
left join NumberOfOrders N on N.ProductID=P.ProductID
group by
N.OrderYear,
P.ProductName,
N.Orders
order by
N.OrderYear asc,
N.Orders desc

/*7
Zadanie 15. (*)
Korzystaj�c z tabeli Suppliers, rozbuduj zapytanie tak, aby dla ka�dego produktu wy�wietli� dodatkowo nazw� dostawcy danego produktu (Suppliers.CompanyName) � kolumn� nazwij SupplierName.*/

with NumberOfOrders (ProductID, Orders, OrderYear) 
as 
(
	select 
	P.ProductID,
	count(distinct O.OrderID) as Orders,
	year(O1.OrderDate) as OrderYear
	from Products P 
	left join [Order Details] O on P.ProductID=O.ProductID
	left join Orders O1 on O1.OrderID=O.OrderID
	group by 
	P.ProductID,
	year(O1.OrderDate)
)

select 
N.OrderYear,
P.ProductName,
S.CompanyName as SupplierName,
N.Orders as NumberOfOrders,
sum(P.UnitPrice*N.Orders) as TotalValue
from Products P
left join NumberOfOrders N on N.ProductID=P.ProductID
left join Suppliers S on S.SupplierID=P.SupplierID
group by
N.OrderYear,
P.ProductName,
S.CompanyName,
N.Orders
order by
N.OrderYear asc,
N.Orders desc
