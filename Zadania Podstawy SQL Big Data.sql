use [Northwind]
GO

--Zadanie 1.
--Korzystaj¹c z tabeli Products oraz Categories wyœwietl nazwê produktu (Products.ProductName) oraz nazwê kategorii (Categories.CategoryName), do której nale¿y produktów.
SELECT 
P.ProductName,
C.CategoryName
from Products P
left join Categories C on C.CategoryID=P.CategoryID
order by P.ProductName

--Zadanie 2. (*)
--Korzystaj¹c z tabeli Suppliers, rozbuduj poprzednie tak, aby równie¿ zaprezentowaæ nazwê dostawcy danego produktu (CompanyName) – kolumnê nazwij SupplierName.
--Wynik posortuj malej¹co po cenie jednostkowej produktu.

SELECT 
P.ProductName,
C.CategoryName,
S.CompanyName
from Products P
left join Categories C on C.CategoryID=P.CategoryID
left join Suppliers S on P.SupplierID=S.SupplierID
order by P.UnitPrice desc

/*Zadanie 3.
Korzystaj¹c z tabeli Products wyœwietl nazwy produktów (ProductName) z najwy¿sz¹ cen¹ jednostkow¹ w danej kategorii (UnitPrice).
Wynik posortuj po nazwie produktu (rosn¹co).*/

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
Korzystaj¹c z tabeli Products wyœwietl nazwy produktów, których cena jednostkowa jest wiêksza ni¿ wszystkie œrednie ceny produktów wyliczone dla pozosta³ych kategorii 
(innych ni¿ ta, do której nale¿y dany produkt. Wynik posortuj po cenie jednostkowej (malej¹co).*/

--PRAWDOPODOBNIE NIEPOPRAWNy WYNIK NA SCREENIE?? --NIEWIADOMO, MYŒLE ZE MOJE ROZWI¥ZANIE JEST POPRWNE

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
Korzystaj¹c z tabeli Order Details, rozbuduj poprzednie zapytanie, tak, aby wyœwietliæ równie¿ maksymaln¹ liczbê zamówionych sztuk (Quantity) danego produktu w jednym zamówieniu (w danym OrderID).*/

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
Korzystaj¹c z tabel Products oraz Order Details wyœwietl identyfikatory kategorii (CategoryID) oraz sumê wszystkie wartoœci zamówieñ produktów w danego kategorii 
([Order Details].UnitPrice * [Order Details].Quantitiy) bez uwzglêdnienia zni¿ki. Wynik powinien zawieraæ jedynie te kategorie, dla których ww. suma jest wiêksza ni¿ 200 000.
Wynik posortuj sumie wartoœci zamówieñ.*/

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
Korzystaj¹c z tabeli Categories, zaktualizuj poprzednie zapytanie tak, aby zwróci³o oprócz identyfikatora kategorii równie¿ jej nazwê.*/

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
Korzystaj¹c z tabel Orders oraz Employees wyœwietl liczbê zamówieñ, które zosta³y wys³ane (ShipRegion) do innych regionów ni¿ te, w zamówieniach obs³u¿onych przez pracownika Robert King 
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
Korzystaj¹c z tabeli Orders wyœwietl wszystkie kraje wysy³ki (ShipCountry), dla których wystêpuj¹ rekordy (zamówienia), które maj¹ wype³nion¹ wartoœæ w polu ShipRegion jak i rekordy z wartoœci¹ NULL.*/
-- Brzmi nie po polsku

/*Zadanie 10.
Korzystaj¹c z odpowiednich tabel wyœwietl identyfikator produktu (Products.ProductID), nazwê produktu (Products.ProductName), kraj i miasto dostawcy 
(Suppliers.Country, Suppliers.City – nazwij je odpowiednio: SupplierCountry oraz SupplierCity) oraz kraj i miasto dostawy danego produktu (Orders.ShipCountry, Orders.ShipCity). 
Wynik ogranicz do takich produktów, które zosta³y wys³ane choæ raz do tego samego kraju, z którego pochodzi ich dostawca. Dodatkowo wynik rozszerz o informacjê czy oprócz kraju 
zgadza siê równie¿ region dostawcy produktu z regionem jego wys³ania – kolumnê nazwij FullMatch, która przyjmie wartoœci Y/N.
Wynik posortuj tak, aby jakby pierwsze zosta³y wyœwietlone posortowane alfabetycznie produkty, dla których zachodzi pe³na zgodnoœæ.*/

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
Rozbuduj poprzednie zapytanie tak, aby wzi¹æ pod uwagê równie¿ region, z którego pochodzi dostawy jak i region wysy³ki. Kolumna FullMatch powinna posiadaæ nastêpuj¹cy zbiór wartoœci:
• Y – dla pe³nej zgodnoœci trzech wartoœci
• N (the region doesn't match) – dla zgodnoœci kraju i miasta, ale nie regionu
• N – dla braku zgodnoœci
Do wyniku dodaj równie¿ pola zawieraj¹ce region: Suppliers.Region (nazwij je SupplierRegion) oraz Orders.ShipRegion)*/

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
Korzystaj¹c z tabeli Products zweryfikuj, czy istniej¹ dwa (lub wiêcej) produkty o tej samej nazwie. Zapytanie powinno zwróciæ w kolumnie DuplicatedProductsFlag wartoœæ Yes lub No:*/

select distinct
case when
	P1.ProductID<>P2.ProductID then 'Yes'
	else 'No' end as DuplicatedProductsFlag
from Products P1
left join Products P2 on P1.ProductName=P2.ProductName


/*Zadanie 13.
Korzystaj¹c z tabel Products oraz Order Details wyœwietl nazwy produktów wraz z informacj¹ na ilu zamówieniach pojawi³y siê dane produkty.
Wynik posortuj tak, aby w pierwszej kolejnoœci pojawi³y siê produkty, które najczêœciej pojawiaj¹ siê na zamówieniach.*/


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
Korzystaj¹c z tabeli Orders rozbuduj poprzednie zapytanie tak, aby powy¿sz¹ analizê zaprezentowaæ w kontekœcie poszczególnych lat (Orders.OrderDate) – kolumnê nazwij OrderYear.
Tym razem wynik posortuj, tak, aby w pierwszej kolejnoœci wyœwietliæ produkty najczêœciej pojawiaj¹ce siê na zamówieniach w kontekœcie danego roku, czyli w pierwszej kolejnoœci 
interesuje nas rok: 1996, póŸniej 1997 itd.*/

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
Korzystaj¹c z tabeli Suppliers, rozbuduj zapytanie tak, aby dla ka¿dego produktu wyœwietliæ dodatkowo nazwê dostawcy danego produktu (Suppliers.CompanyName) – kolumnê nazwij SupplierName.*/

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
