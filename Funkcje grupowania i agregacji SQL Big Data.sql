use [Northwind]
go

/*Zadanie 1.
Korzystaj¹c z tabeli Products wyœwietl maksymaln¹ cenê jednostkow¹ dostêpnych produktów (UnitPrice).*/

select
max(UnitPrice) as MaxUnitPrice
from Products

/*Zadanie 2.
Korzystaj¹c z tabeli Products oraz Categories wyœwietl sumê wartoœci produktów w magazynie (UnitPrice * UnitsInStock) z podzia³em na kategorie (w wyniku uwzglêdnij nazwê 
kategorii oraz produktu przypisane do jakiejœ kategorii). Wynik posortuj wg kategorii (rosn¹co).*/

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
Rozbuduj zapytanie z zadania 2. tak, aby zaprezentowane zosta³y jedynie kategorie, dla których wartoœæ produktów przekracza 10000. Wynik posortuj malej¹co wg wartoœci produktów.*/

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
Korzystaj¹c z tabeli Suppliers, Products oraz Order Details wyœwietl informacje na ilu unikalnych zamówieniach pojawi³y siê produkty danego dostawcy. Wyniki posortuj alfabetycznie po nazwie dostawcy.*/

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
Korzystaj¹c z tabel Orders, Customers oraz Order Details przedstaw œredni¹, minimaln¹ oraz maksymaln¹ wartoœæ zamówienia (zaokr¹glonego do dwóch miejsc po przecinku, bez uwzglêdnienia zni¿ki) 
dla ka¿dego z klientów (Customers.CustomerID). Wyniki posortuj zgodnie ze œredni¹ wartoœci¹ zamówienia – malej¹co. Pamiêtaj, aby œredni¹, minimaln¹ oraz maksymaln¹ wartoœæ zamówienia wyliczyæ 
bazuj¹c na jego wartoœci, czyli sumie iloczynów cen jednostkowych oraz wielkoœci zamówienia.*/

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
Korzystaj¹c z tabeli Orders wyœwietl daty (OrderDate), w których by³o wiêcej ni¿ jedno zamówienie uwzglêdniaj¹c dok³adn¹ liczbê zamówieñ. Datê zamówienia wyœwietl w formacie YYYY-MM-DD. 
Wynik posortuj malej¹co wg liczby zamówieñ.*/

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
Korzystaj¹c z tabeli Orders przeanalizuj liczbê zamówieñ w 3 wymiarach: Rok i miesi¹c, rok oraz ca³oœciowe podsumowanie. Wynik posortuj po polu „Rok-miesi¹c”.*/