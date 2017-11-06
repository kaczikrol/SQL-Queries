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
order by P.ProductName