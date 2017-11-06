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
order by P.ProductName