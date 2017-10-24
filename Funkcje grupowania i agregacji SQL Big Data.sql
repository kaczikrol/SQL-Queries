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