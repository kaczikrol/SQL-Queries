--FUNKCJE ANALITYCZNE

/*
Zadanie 1.
Korzystaj¹c tabeli Products zaprojektuj zapytanie, które zwróci œredni¹ jednostkow¹ cenê wszystkich produktów. Wynik zaokr¹glij do dwóch miejsc po przecinku.
*/

select 
AVG(UnitPrice) AS AvgUnitPrice
from Products

/*
Zadanie 2.
Korzystaj¹c z tabel Products oraz Categories, zaprojektuj zapytanie, które zwróci nazwê kategorii oraz œredni¹ jednostkow¹ cenê produktów w danej kategorii. 
Œredni¹ zaokr¹glij do dwóch miejsc po przecinku. Wynik posortuj alfabetycznie po nazwie kategorii.
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
Korzystaj¹c z tabel Products oraz Categories zaprojektuj zapytanie, które zwróci wszystkie produkty (ProductName) wraz z kategoriami, 
do których nale¿¹ (CategoryName) oraz œredni¹ jednostkow¹ cenê dla wszystkich produktów. Analiza powinna obejmowaæ produkty ze wszystkich kategorii z wyj¹tkiem Beverages. 
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
Rozbuduj poprzednie zapytanie o minimaln¹ i maksymaln¹ jednostkow¹ cenê dla wszystkich produktów. Tym razem interesuj¹ nas wszystkie produkty (usuñ ograniczenie na kategoriê).
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
Rozbuduj poprzednie zapytanie o œredni¹ jednostkow¹ cenê w kategorii i dla danego dostawcy.
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
Rozbuduj poprzednie zapytanie o liczbê produktów w danej kategorii.
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
Korzystaj¹c z tabeli Orders oraz Customers przygotuj zapytanie, które wyœwietli identyfikator zamówienie (OrderID), nazwê klienta (CompanyName) oraz numer rekordu. 
Numeracja rekordów powinna byæ zgodna z dat¹ zamówienia posortowan¹ rosn¹co. Wyniki posortuj zgodnie z identyfikatorem zamówienia (rosn¹co).
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
Zaktualizuj poprzednie zapytanie tak, aby wynik zosta³ posortowany w pierwszej kolejnoœci po nazwie klienta (rosn¹ca), a w drugiej po dacie zamówienia (malej¹co).
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
Korzystaj¹c z tabel Products oraz Categories, zaprojektuj zapytanie uwzglêdniaj¹ce stronicowanie (wyznaczone rosn¹co po identyfikatorze produktu), które pozwoli wyœwietliæ zadan¹ 
stronê zawieraj¹c¹ informacje o produktach: identyfikator, nazwa produktu, nazwa kategorii, jednostokowa cena produktu, œrednia jednostkowa cena produktu w danej kategorii oraz 
numer strony (numer wiersza nie powinien byæ wyœwietlony). Wielkoœæ strony oraz jej numer powinny byæ parametryzowalne. Wynik (ju¿ po uwzglêdnieniu stronicowania!) powinien zostaæ 
posortowany po nazwie produktu (alfabetycznie, rosn¹co).
Do realizacji zadania mo¿na u¿yæ CTE lub podzapytania.
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
Korzystaj¹c z tabel Products oraz Categories oraz funkcji analitycznych stwórz ranking najdro¿szych (wg jednostkowej ceny) 5 produktów w danej kategorii. 
W przypadku produktów o tej samej wartoœci na ostatniej pozycji, uwzglêdnij wszystkie z nich. Je¿eli by³ na poprzednich pozycjach to ka¿dy z produktów jest zaliczany osobno. 
Wyniki posortuj wg kategorii (rosn¹co) oraz miejsca w rankingu (rosn¹co).
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
Poni¿sze zadanie, które rozwi¹zywaliœmy za pomoc¹ CTE, teraz spróbuj rozwi¹zaæ z uwzglêdnieniem funkcji analitycznych. W tym przypadku równie¿ mo¿esz (nie musisz!) wykorzystaæ CTE.
Korzystaj¹c z tabel Products oraz Order Details wyœwietl wszystkie identyfikatory (Products.ProductID) i nazwy produktów (Products.ProductName), których maksymalna wartoœæ zamówienia bez 
uwzglêdnienia zni¿ki (UnitPrice*Quantity) jest mniejsza od œredniej w danej kategorii. Inaczej mówi¹c – nie istnieje wartoœæ zamówienia wiêksza ni¿ œrednia w kategorii do której 
nale¿y dany Produkt.
Wynik posortuj rosn¹co wg identyfikatora produktu.
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
Korzystaj¹c z tabeli Products oraz Categories wyœwietl identyfikator produktu, kategoriê, do której nale¿y dany produkt, jednostkow¹ cenê oraz wyliczon¹ sumê bie¿¹c¹ jednostkowej ceny 
produktów w dalej kategorii. Suma bie¿¹ca, zdefiniowana jako suma wszystkich poprzedzaj¹cych rekordów (cen jednostkowych produktów), powinna byæ wyliczona na zbiorze danych posortowanych 
po jednostkowej cenie produktu – rosn¹co.
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
Rozbuduj poprzednie zapytanie o wyliczenie maksymalnej wartoœci ceny jednostkowej z okna obejmuj¹cego 2 poprzednie wiersze i 2 nastêpuj¹ce po bie¿¹cym. 
Dodatkowo wylicz œredni¹ krocz¹c¹ z ceny jednostkowej sk³adaj¹cej siê z okna obejmuj¹cego 2 poprzednie rekordy oraz aktualny. Nie zmieniaj sortowania – wszystkie zbiory powinny byæ 
uporz¹dkowane rosn¹co po cenie jednostkowej produktu.
*/

