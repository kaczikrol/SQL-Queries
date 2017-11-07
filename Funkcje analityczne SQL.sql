--FUNKCJE ANALITYCZNE

/*
Zadanie 1.
Korzystaj�c tabeli Products zaprojektuj zapytanie, kt�re zwr�ci �redni� jednostkow� cen� wszystkich produkt�w. Wynik zaokr�glij do dw�ch miejsc po przecinku.
*/

select 
AVG(UnitPrice) AS AvgUnitPrice
from Products

/*
Zadanie 2.
Korzystaj�c z tabel Products oraz Categories, zaprojektuj zapytanie, kt�re zwr�ci nazw� kategorii oraz �redni� jednostkow� cen� produkt�w w danej kategorii. 
�redni� zaokr�glij do dw�ch miejsc po przecinku. Wynik posortuj alfabetycznie po nazwie kategorii.
*/

select 
distinct C.CategoryName,
round(AVG(P.UnitPrice) OVER (PARTITION BY C.CategoryName),2) as AvgCategoryProductPrice
from Products P 
join Categories C on C.CategoryID=P.CategoryID
order by 
C.CategoryName

/*
Zadanie 3.
Korzystaj�c z tabel Products oraz Categories zaprojektuj zapytanie, kt�re zwr�ci wszystkie produkty (ProductName) wraz z kategoriami, 
do kt�rych nale�� (CategoryName) oraz �redni� jednostkow� cen� dla wszystkich produkt�w. Analiza powinna obejmowa� produkty ze wszystkich kategorii z wyj�tkiem Beverages. 
Wynik posortuj alfabetycznie po nazwie produktu.
*/

select 
P.ProductName,
C.CategoryName,
P.UnitPrice,
round(AVG(P.UnitPrice) OVER (),2) as AvgProductsAll
--round(AVG(P.UnitPrice) OVER (Partition by C.CategoryName),2) as AvgProductsInCategory
from Products P
join Categories C on C.CategoryID=P.CategoryID
where 
C.CategoryName <> 'Beverages'
order by P.ProductName

/*
Zadanie 4. (*)
Rozbuduj poprzednie zapytanie o minimaln� i maksymaln� jednostkow� cen� dla wszystkich produkt�w. Tym razem interesuj� nas wszystkie produkty (usu� ograniczenie na kategori�).
*/

select
P.ProductName,
C.CategoryName,
P.UnitPrice,
(P.UnitPrice-round(AVG(P.UnitPrice) OVER(),2)) as DeltaUnitPrice,
round(AVG(P.UnitPrice) OVER(),2) as AvgUnitPriceAllProducts,
round(MAX(P.UnitPrice) OVER(),2) as MaxUnitPriceAllProducts,
round(MIN(P.UnitPrice) OVER(),2) as MinUnitPriceAllProducts
from Products P 
join Categories C on P.CategoryID=C.CategoryID

/*
Zadanie 5. (*)
Rozbuduj poprzednie zapytanie o �redni� jednostkow� cen� w kategorii i dla danego dostawcy.
*/

SELECT
P.ProductName,
C.CategoryName,
P.SupplierID,
round(AVG(P.UnitPrice) OVER(),2) as AvgUnitPriceAllProducts,
round(MAX(P.UnitPrice) OVER(),2) as MaxUnitPriceAllProducts,
round(MIN(P.UnitPrice) OVER(),2) as MinUnitPriceAllProducts,
round(AVG(P.UnitPrice) OVER (PARTITION BY C.CategoryName,P.SupplierID),2) as AvgUnitPriceCategSupp
from Products P 
join Categories C on P.CategoryID=C.CategoryID 
order by P.ProductName

/*
Zadanie 6. (*)
Rozbuduj poprzednie zapytanie o liczb� produkt�w w danej kategorii.
*/

SELECT
P.ProductName,
C.CategoryName,
P.SupplierID,
round(AVG(P.UnitPrice) OVER(),2) as AvgUnitPriceAllProducts,
round(MAX(P.UnitPrice) OVER(),2) as MaxUnitPriceAllProducts,
round(MIN(P.UnitPrice) OVER(),2) as MinUnitPriceAllProducts,
round(AVG(P.UnitPrice) OVER (PARTITION BY C.CategoryName,P.SupplierID),2) as AvgUnitPriceCategSupp,
count(P.ProductName) OVER (PARTITION BY C.CategoryName) as ProductsInCategory
from Products P 
join Categories C on P.CategoryID=C.CategoryID 
order by 
P.ProductName

/*
Zadanie 7.
Korzystaj�c z tabeli Orders oraz Customers przygotuj zapytanie, kt�re wy�wietli identyfikator zam�wienie (OrderID), nazw� klienta (CompanyName) oraz numer rekordu. 
Numeracja rekord�w powinna by� zgodna z dat� zam�wienia posortowan� rosn�co. Wyniki posortuj zgodnie z identyfikatorem zam�wienia (rosn�co).
*/

select 
O.OrderID,
C.CompanyName,
O.OrderDate,
ROW_NUMBER() OVER(ORDER BY O.OrderDate) as RowNumber
from Orders O
inner join Customers C on O.CustomerID=C.CustomerID
order by RowNumber 

/*
Zadanie 8. (*)
Zaktualizuj poprzednie zapytanie tak, aby wynik zosta� posortowany w pierwszej kolejno�ci po nazwie klienta (rosn�ca), a w drugiej po dacie zam�wienia (malej�co).
*/

select 
O.OrderID,
C.CompanyName,
O.OrderDate,
ROW_NUMBER() OVER(ORDER BY O.OrderDate) as RowNumber
from Orders O
inner join Customers C on O.CustomerID=C.CustomerID
order by C.CompanyName asc,RowNumber desc


/*
Zadanie 9.
Korzystaj�c z tabel Products oraz Categories, zaprojektuj zapytanie uwzgl�dniaj�ce stronicowanie (wyznaczone rosn�co po identyfikatorze produktu), kt�re pozwoli wy�wietli� zadan� 
stron� zawieraj�c� informacje o produktach: identyfikator, nazwa produktu, nazwa kategorii, jednostokowa cena produktu, �rednia jednostkowa cena produktu w danej kategorii oraz 
numer strony (numer wiersza nie powinien by� wy�wietlony). Wielko�� strony oraz jej numer powinny by� parametryzowalne. Wynik (ju� po uwzgl�dnieniu stronicowania!) powinien zosta� 
posortowany po nazwie produktu (alfabetycznie, rosn�co).
Do realizacji zadania mo�na u�y� CTE lub podzapytania.
*/

declare
	@pageNum as int = 1,
	@pageSize as int = 10;

WITH OrdersWithRowNum AS 
(
select 
ROW_NUMBER() OVER(ORDER BY P.ProductID) as rowNumber,
P.ProductID,
P.ProductName,
C.CategoryName,
round(AVG(P.UnitPrice) OVER (PARTITION BY C.CategoryName),2) as AvgPriceCategory
from Products P
inner join Categories C on P.CategoryID=C.CategoryID
)

select 
@pageNum as PageNumber,
ProductID,
ProductName,
CategoryName
from OrdersWithRowNum
--Tutaj odgrywa sie cala zabawa ze stronicowaniem----------------
where
rowNumber between (@pageNum-1)*@pageSize and @pageNum*@pageSize
------------------------------------------------------------------
order by rowNumber

/*
Korzystajac z Sales by Category przedstaw zadeklarowany dowolnie procent ze sprzedazy danej kategorii
*/

declare 
	@percent as float =0.20;

with CategorySales (CategoryName,SalesValue) as 
(
select
CategoryName,
sum(ProductSales) as SalesValue
from
[Sales by Category]
group by
CategoryName
)

select
CategoryName,
SalesValue,
@percent*SalesValue as PercentOfSalesValue
from
CategorySales

/*
Zadanie 10.
Korzystaj�c z tabel Products oraz Categories oraz funkcji analitycznych stw�rz ranking najdro�szych (wg jednostkowej ceny) 5 produkt�w w danej kategorii. 
W przypadku produkt�w o tej samej warto�ci na ostatniej pozycji, uwzgl�dnij wszystkie z nich. Je�eli by� na poprzednich pozycjach to ka�dy z produkt�w jest zaliczany osobno. 
Wyniki posortuj wg kategorii (rosn�co) oraz miejsca w rankingu (rosn�co).
*/

With WindowTable (Category, ProductName, UnitPrice, RowNumber, RankRow, DenseRankRow) as 
(
select
C.CategoryName,
P.ProductName,
P.UnitPrice,
ROW_NUMBER() OVER (PARTITION BY P.CategoryID ORDER BY P.UnitPrice) as RowNumberUnitPrice,
RANK() OVER (PARTITION BY P.CategoryID ORDER BY P.UnitPrice desc) as RankPerUnitPrice,
DENSE_RANK() OVER (PARTITION BY P.CategoryID ORDER BY P.UnitPrice desc) as DenseRankPerUnitPrice
from Products P 
inner join Categories C on P.CategoryID=C.CategoryID
)

select
Category,
ProductName,
UnitPrice,
RankRow
from WindowTable
where 
RankRow<=5
order by Category asc, RankRow asc

/*
Zadanie 11.
Poni�sze zadanie, kt�re rozwi�zywali�my za pomoc� CTE, teraz spr�buj rozwi�za� z uwzgl�dnieniem funkcji analitycznych. W tym przypadku r�wnie� mo�esz (nie musisz!) wykorzysta� CTE.
Korzystaj�c z tabel Products oraz Order Details wy�wietl wszystkie identyfikatory (Products.ProductID) i nazwy produkt�w (Products.ProductName), kt�rych maksymalna warto�� zam�wienia bez 
uwzgl�dnienia zni�ki (UnitPrice*Quantity) jest mniejsza od �redniej w danej kategorii. Inaczej m�wi�c � nie istnieje warto�� zam�wienia wi�ksza ni� �rednia w kategorii do kt�rej 
nale�y dany Produkt.
Wynik posortuj rosn�co wg identyfikatora produktu.
*/

WITH AnalyticsTable (ProductID, ProductName, OrderValue, MaxProductOrderValue, AvgValueInCategory) as 
(
select
P.ProductID,
P.ProductName,
O.UnitPrice*O.Quantity as OrderValue,
MAX(O.UnitPrice*O.Quantity) OVER (PARTITION BY P.ProductID) AS MaxProductOrderValue,
AVG(O.UnitPrice*O.Quantity) OVER (PARTITION BY P.CategoryID) AS AvgInCategory
from Products P 
inner join [Order Details] O on O.ProductID=P.ProductID
)

select 
distinct ProductID,
ProductName
from AnalyticsTable
where
MaxProductOrderValue<AvgValueInCategory

/*
Zadanie 12.
Korzystaj�c z tabeli Products oraz Categories wy�wietl identyfikator produktu, kategori�, do kt�rej nale�y dany produkt, jednostkow� cen� oraz wyliczon� sum� bie��c� jednostkowej ceny 
produkt�w w dalej kategorii. Suma bie��ca, zdefiniowana jako suma wszystkich poprzedzaj�cych rekord�w (cen jednostkowych produkt�w), powinna by� wyliczona na zbiorze danych posortowanych 
po jednostkowej cenie produktu � rosn�co.
*/

select
P.ProductID,
P.ProductName,
C.CategoryName,
P.UnitPrice,
SUM(P.UnitPrice) OVER (PARTITION BY C.CategoryName ORDER BY P.UnitPrice asc,P.ProductID) as RunningSum
from Products P 
inner join Categories C on P.CategoryID=C.CategoryID

/*
Zadanie 13. (*)
Rozbuduj poprzednie zapytanie o wyliczenie maksymalnej warto�ci ceny jednostkowej z okna obejmuj�cego 2 poprzednie wiersze i 2 nast�puj�ce po bie��cym. 
Dodatkowo wylicz �redni� krocz�c� z ceny jednostkowej sk�adaj�cej si� z okna obejmuj�cego 2 poprzednie rekordy oraz aktualny. Nie zmieniaj sortowania � wszystkie zbiory powinny by� 
uporz�dkowane rosn�co po cenie jednostkowej produktu.
*/

