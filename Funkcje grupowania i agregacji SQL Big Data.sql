use [Northwind]
go

/*Zadanie 1.
Korzystaj�c z tabeli Products wy�wietl maksymaln� cen� jednostkow� dost�pnych produkt�w (UnitPrice).*/

select
max(UnitPrice) as MaxUnitPrice
from Products

/*Zadanie 2.
Korzystaj�c z tabeli Products oraz Categories wy�wietl sum� warto�ci produkt�w w magazynie (UnitPrice * UnitsInStock) z podzia�em na kategorie (w wyniku uwzgl�dnij nazw� 
kategorii oraz produktu przypisane do jakiej� kategorii). Wynik posortuj wg kategorii (rosn�co).*/

select 
C.CategoryName,
sum(P.UnitPrice*P.UnitsInStock) ValueOfProducts
from  Products P
join Categories C on C.CategoryID=P.CategoryID
group by
C.CategoryName
order by
C.CategoryName

/*Zadanie 3. (*)
Rozbuduj zapytanie z zadania 2. tak, aby zaprezentowane zosta�y jedynie kategorie, dla kt�rych warto�� produkt�w przekracza 10000. Wynik posortuj malej�co wg warto�ci produkt�w.*/

select 
C.CategoryName,
sum(P.UnitPrice*P.UnitsInStock) ValueOfProducts
from  Products P
join Categories C on C.CategoryID=P.CategoryID
group by
C.CategoryName
having
sum(P.UnitPrice*P.UnitsInStock)>'10000'
order by
ValueOfProducts desc

/*Zadanie 4.
Korzystaj�c z tabeli Suppliers, Products oraz Order Details wy�wietl informacje na ilu unikalnych zam�wieniach pojawi�y si� produkty danego dostawcy. Wyniki posortuj alfabetycznie po nazwie dostawcy.*/

select 
S.CompanyName,
count(distinct O.OrderID) as NumberOfOrders
from Products P
join [Order Details] O on O.ProductID=P.ProductID
join Suppliers S on S.SupplierID=P.SupplierID
group by
S.CompanyName
order by
S.CompanyName

/*Zadanie 5.
Korzystaj�c z tabel Orders, Customers oraz Order Details przedstaw �redni�, minimaln� oraz maksymaln� warto�� zam�wienia (zaokr�glonego do dw�ch miejsc po przecinku, bez uwzgl�dnienia zni�ki) 
dla ka�dego z klient�w (Customers.CustomerID). Wyniki posortuj zgodnie ze �redni� warto�ci� zam�wienia � malej�co. Pami�taj, aby �redni�, minimaln� oraz maksymaln� warto�� zam�wienia wyliczy� 
bazuj�c na jego warto�ci, czyli sumie iloczyn�w cen jednostkowych oraz wielko�ci zam�wienia.*/

with AnalyseTable (CustomerID, CustomerName, OrderID, OrderValue)
as 
(
	select
	C.CustomerID,
	C.CompanyName,
	OD.OrderID,
	sum(OD.Quantity*OD.UnitPrice) as OrderValue
	from Products P
	join [Order Details] OD on P.ProductID=OD.ProductID
	join Orders O on O.OrderID=OD.OrderID
	join Customers C on C.CustomerID=O.CustomerID
	group by
	C.CustomerID,
	C.CompanyName,
	OD.OrderID
)

select 
A.CustomerName,
round(min(A.OrderValue),2) as MinOrderValue,
round(max(A.OrderValue),2) as MaxOrderValue,
round(avg(A.OrderValue),2) as AvgOrderValue
from AnalyseTable A
group by
A.CustomerName
order by
AvgOrderValue desc

/*Zadanie 6.
Korzystaj�c z tabeli Orders wy�wietl daty (OrderDate), w kt�rych by�o wi�cej ni� jedno zam�wienie uwzgl�dniaj�c dok�adn� liczb� zam�wie�. Dat� zam�wienia wy�wietl w formacie YYYY-MM-DD. 
Wynik posortuj malej�co wg liczby zam�wie�.*/

select
convert(date,O.OrderDate) as OrderDate,
count(distinct O.OrderID) as Orders
from Orders O
group by 
O.OrderDate
having 
count(distinct O.OrderID)>1
order by
Orders desc 


/*Zadanie 7.
Korzystaj�c z tabeli Orders przeanalizuj liczb� zam�wie� w 3 wymiarach: Rok i miesi�c, rok oraz ca�o�ciowe podsumowanie. Wynik posortuj po polu �Rok-miesi�c�.*/

select 
DATEPART(YYYY,OrderDate) as OrderYear,
DATEPART(MM,OrderDate) as OrderMonth,
count(OrderID) as Orders,
--GROUPING(DATEPART(YYYY,OrderDate)) as YearGroup,
--GROUPING(DATEPART(MM,OrderDate)) as MonthGroup,
CASE 
	WHEN GROUPING(DATEPART(YYYY,OrderDate))=0 AND GROUPING(DATEPART(MM,OrderDate))=0 THEN 'Year&Month'
	WHEN GROUPING(DATEPART(YYYY,OrderDate))=0 AND GROUPING(DATEPART(MM,OrderDate))=1 THEN 'Year'
	WHEN GROUPING(DATEPART(YYYY,OrderDate))=1 AND GROUPING(DATEPART(MM,OrderDate))=1 THEN 'Total'	
END AS GroupingLevel
from Orders
group by rollup(DATEPART(YYYY,OrderDate),DATEPART(MM,OrderDate))
order by GroupingLevel, OrderYear, OrderMonth


/*4
Zadanie 8.
Korzystaj�c z tabeli Orders przedstaw analizuj� liczby zam�wie� ze wzgl�du na wymiary:
� Kraj, region oraz miasto dostawy
� Kraj oraz region dostawy
� Kraj dostawy
� Podsumowanie
Dodaj kolumn� GroupingLevel obja�niaj�c� poziom grupowania, kt�ra dla poszczeg�lnych wymiar�w przyjmie warto�ci odpowiednio:
� Country & Region & City
� Country & Region
� Country
� Total
Pole region mo�e posiada� warto�ci puste � oznacz takie warto�ci jako �Not Provided�
Wynik posortuj alfabetycznie zgodnie z krajem dostawy.
Oczekiwany rezultat (cz�ciowy; liczba wszystkich zwr�conych rekord�w: 127):*/

select
isnull(ShipCountry,'N/A') as ShipCountry,
isnull(ShipRegion,'N/A') as ShipRegion,
ISNULL(ShipCity,'N/A') AS ShipCity,
count(OrderID) as Orders,
--GROUPING(ShipCountry) as 'Country Grp',
--GROUPING(ShipRegion) as 'Region Grp',
--GROUPING(ShipCity) as 'City Grp',
CASE 
	WHEN GROUPING(ShipCountry)=0 and GROUPING(ShipRegion)=0 and GROUPING(ShipCity)=0 THEN 'Country&Region&City'
	WHEN GROUPING(ShipCountry)=0 and GROUPING(ShipRegion)=0 and GROUPING(ShipCity)=1 THEN 'Country&Region'
	WHEN GROUPING(ShipCountry)=0 and GROUPING(ShipRegion)=1 and GROUPING(ShipCity)=1 THEN 'Country'
	WHEN GROUPING(ShipCountry)=1 and GROUPING(ShipRegion)=1 and GROUPING(ShipCity)=1 THEN 'Total'
END AS GroupingLevel
from Orders
group by rollup (ShipCountry,ShipRegion,ShipCity)
order by GroupingLevel, ShipCountry, ShipRegion, ShipCity

/*
Zadanie 9.
Korzystaj�c z tabel Orders, Order Details, Customers przedstaw analiz� sumy warto�ci zam�wie� (bez uwzgl�dnienia zni�ki) jako pe�na analiza (wszystkie kombinacje) wymiar�w:
� Rok (Order.OrderDate)
� Klient (Customers.CompanyName)
� Podsumowanie ca�o�ciowe
Uwzgl�dnij jedynie rekordy, kt�re posiadaj� wszystkie wymagane informacje (nie potrzeba po��cze� zewn�trznych).
Wynik posortuj po nazwie Klienta (alfabetycznie).
Oczekiwany rezultat (cz�ciowy; liczba wszystkich zwr�conych rekord�w: 327):*/

select 
DATEPART(YYYY,O.OrderDate) as OrderYear,
C.CompanyName as Customer,
sum(OD.Quantity*OD.UnitPrice) as OrderValue,
GROUPING(DATEPART(YYYY,O.OrderDate)),
grouping(C.CompanyName),
CASE 
	WHEN GROUPING(DATEPART(YYYY,O.OrderDate))=1 and grouping(C.CompanyName)=1 then 'Total'
	WHEN GROUPING(DATEPART(YYYY,O.OrderDate))=1 and grouping(C.CompanyName)=0 then 'Company'
	when GROUPING(DATEPART(YYYY,O.OrderDate))=0 and grouping(C.CompanyName)=1 then 'Year' 
	when GROUPING(DATEPART(YYYY,O.OrderDate))=0 and grouping(C.CompanyName)=0 then 'Year&Company'
END AS GroupingLevel
from Orders O
inner join [Order Details] OD on O.OrderID=OD.OrderID
inner join Customers C on O.CustomerID=C.CustomerID
group by cube (DATEPART(YYYY,O.OrderDate),C.CompanyName)
order by Customer,GroupingLevel

/*
Zadanie 10. (*)
Zmodyfikuj zapytanie stworzone w zadaniu 9. tak, aby zamiast nazwy uwzgl�dni� kraj (Customers.Country) i region (Customers.Region) klienta (wymiar powinien sk�ada� si� z dw�jki: 
kraj oraz region; podsumowanie nie powinno by� liczone osobno dla kraju i regionu). Wyniki posortuj po nazwie kraju (alfabetycznie).
Oczekiwany rezultat (cz�ciowy; liczba wszystkich zwr�conych rekord�w: 134):*/

select 
DATEPART(YYYY,O.OrderDate) as OrderYear,
CONCAT(C.Country,C.Region) as 'Country&Region',
sum(OD.Quantity*OD.UnitPrice) as OrderValue,
CASE 
	WHEN GROUPING(DATEPART(YYYY,O.OrderDate))=1 and grouping(CONCAT(C.Country,C.Region))=1 then 'Total'
	WHEN GROUPING(DATEPART(YYYY,O.OrderDate))=1 and grouping(CONCAT(C.Country,C.Region))=0 then 'Country&Region'
	when GROUPING(DATEPART(YYYY,O.OrderDate))=0 and grouping(CONCAT(C.Country,C.Region))=1 then 'Year' 
	when GROUPING(DATEPART(YYYY,O.OrderDate))=0 and grouping(CONCAT(C.Country,C.Region))=0 then 'Year&Country&Region'
END AS GroupingLevel
from Orders O
inner join [Order Details] OD on O.OrderID=OD.OrderID
inner join Customers C on O.CustomerID=C.CustomerID
group by cube (DATEPART(YYYY,O.OrderDate),CONCAT(C.Country,C.Region))
order by [Country&Region],GroupingLevel

/*
Zadanie 11.
Korzystaj�c z tabel Orders, Orders Details, Customers, Products, Suppliers oraz Categories przedstaw analiz� sumy warto�ci zam�wie� (bez uwzgl�dnienia zni�ki) dla konkretnych wymiar�w:
� Kategorii (Cateogires.CategoryName)
� Kraju dostawcy (Suppliers.Country)
� Kraju i regionu klienta (Customers.Country, Customers.Region)
Wymiary sk�adaj�ce si� z wi�cej ni� jednego atrybutu powinny by� traktowane ca�o�ciowo (bez grupowa� dla podzbior�w). Nie generuj dodatkowych podsumowa� � uwzgl�dnij dok�adnie wymienione powy�ej wymiary.
Uwzgl�dnij jedynie rekordy, kt�re posiadaj� wszystkie wymagane informacje.
Do wyniku dodaj pole GroupingLevel obja�niaj�c� poziom grupowania, kt�re przyjmie warto�ci odpowiednio dla poszczeg�lnych wymiar�w:
� Category
� Country - Supplier
� Country & Region � Customer
Wynik posortuj w pierwszej kolejno�ci alfabetycznie po kolumnie GroupingLevel (rosn�co), a nast�pnie po kolumnie z sum� warto�ci zam�wie� OrdersValue (malej�co).
Oczekiwany rezultat (cz�ciowy; liczba wszystkich zwr�conych rekord�w: 58):*/


--do analizy!--

select * from Orders
select * from [Order Details]
select * from Customers
select * from Products
select * from Suppliers
select * from Categories

select 
CA.CategoryName as CategoryName,
S.Country as SupplierCountry,
C.Country as CustomerCountry,
C.Region as CustomerRegion,
SUM(OD.Quantity*OD.UnitPrice) as OrderValue,
GROUPING_ID(CA.CategoryName),
GROUPING_ID(S.Country),
GROUPING_ID(C.Country),
GROUPING_ID(C.Region),
CASE 
	WHEN GROUPING_ID(CA.CategoryName)=0 AND GROUPING_ID(S.Country)=1 AND GROUPING_ID(C.Country)=1 AND GROUPING_ID(C.Region)=1 then 'Category'
	WHEN GROUPING_ID(CA.CategoryName)=1 AND GROUPING_ID(S.Country)=0 AND GROUPING_ID(C.Country)=1 AND GROUPING_ID(C.Region)=1 then 'Country-Supplier'
	WHEN GROUPING_ID(CA.CategoryName)=1 AND GROUPING_ID(S.Country)=1 AND GROUPING_ID(C.Country)=0 AND GROUPING_ID(C.Region)=1 then 'Country-Customer'
	WHEN GROUPING_ID(CA.CategoryName)=1 AND GROUPING_ID(S.Country)=1 AND GROUPING_ID(C.Country)=1 AND GROUPING_ID(C.Region)=0 then 'Region-Customer'
END AS GroupingLevel
from Orders O
inner join [Order Details] OD on O.OrderID=OD.OrderID
inner join Customers C on O.CustomerID=C.CustomerID
inner join Products P on P.ProductID=OD.ProductID
inner join Suppliers S on S.SupplierID=P.SupplierID
inner join Categories CA on P.CategoryID=CA.CategoryID
group by cube(CA.CategoryName,S.Country,C.Country,C.Region)
HAVING
	GROUPING_ID(CA.CategoryName)+GROUPING_ID(S.Country)+GROUPING_ID(C.Country)+GROUPING_ID(C.Region)=3
order by GroupingLevel asc, OrderValue desc



/*Zadanie 12.
Korzystaj�c z tabel Orders oraz Shippers przedstaw tabel� zawieraj�c� liczb� zrealizowanych zam�wie� do danego (ShipCountry) przez dan� firm� transportow�. 
Jako wiersze przedstaw kraj dostawy a jako kolumny dostawc�w. Wynik posortuj po nazwie kraju dostawy (alfabetycznie).*/

/*
Federal Shipping
Speedy Express
United Package
*/

select [ShipCountry], [Federal Shipping], [Speedy Express], [United Package]
from 
	(	select O.ShipCountry as ShipCountry,
		S.CompanyName as CompanyName,
		O.OrderID as Orders
		from Orders O
		join Shippers S on S.ShipperID=O.ShipVia) S
		PIVOT
			(
			count(S.Orders) 
			for CompanyName
			in ([Federal Shipping],[Speedy Express],[United Package])
		) 
as AMT


/*
Zadanie w�asne
Przedstaw ilosc zamowien na ktorych pojawil sie dany produkt w danym roku
*/

select [ProductName], [1996], [1997], [1998]
FROM	
	(
	select
	O.OrderID as OrderID,
	P.ProductName as ProductName,
	DATEPART(YYYY,O.OrderDate) as OrderYear
	from Orders O
	join [Order Details] OD on OD.OrderID=O.OrderID
	join Products P on OD.ProductID=P.ProductID			
	) tmp
PIVOT
	(
	count(tmp.OrderID)
	for OrderYear
	in ([1996], [1997], [1998])
	) amt



/*Zadanie w�asne
Pokaz w latach liczbe zamowien przypadajaca na pracownika
*/

select * from Orders
select * from Employees

select [Employee], [1996], [1997], [1998]
from
(
select 
CONCAT(E.LastName,' ',E.FirstName) as Employee,
DATEPART(YYYY,O.OrderDate) as OrderYear,
O.OrderID as Orders
from Orders O
inner join Employees E on O.EmployeeID=E.EmployeeID
) as tmp
PIVOT 
(
count(tmp.Orders)
for tmp.OrderYear in ([1996], [1997], [1998])
) as amt
order by (amt.[1996]+amt.[1997]+amt.[1998]) desc

/*
Zadanie 13. (*)
Uwzgl�dniaj�c tabel� Order Details, zaktualizuj poprzednie zapytanie tak, aby zamiast liczby zrealizowanych zam�wie� pojawi�a si� 
suma warto�ci zam�wie� obs�u�onych przez dan� firm� transportow� wys�anych do danego kraju.*/

select * from Orders
select * from [Order Details]
select * from Shippers


select [ShipCountry],[Federal Shipping], [Speedy Express], [United Package]
from 
(
select
O.ShipCountry as ShipCountry,
S.CompanyName as CompanyName,
(OD.Quantity*OD.UnitPrice) as OrderValue
from 
Orders O 
inner join Shippers S on S.ShipperID=O.ShipVia
inner join [Order Details] OD on O.OrderID=OD.OrderID
) as tmp
PIVOT 
(
sum(tmp.OrderValue)
for tmp.CompanyName in ([Federal Shipping], [Speedy Express], [United Package])
) atm
order by (atm.[Federal Shipping]+atm.[Speedy Express]+atm.[United Package]) desc