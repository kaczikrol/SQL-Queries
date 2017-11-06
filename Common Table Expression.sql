use [Northwind]
go

/*Zadanie 1.
Korzystając z tabeli Products wyświetl wszystkie identyfikator produktów (ProductID) oraz nazwy (ProductName), 
których cena jednostkowa (UnitPrice) jest większa od średniej w danej kategorii. Wynik posortuj wg ceny jednostkowej (UnitPrice).
Zapytanie zrealizuj w dwóch wariantach: bez oraz z uwzględnieniem CTE.*/
--bez cte
select
P.ProductID,
P.ProductName,
P.UnitPrice,
P.CategoryID,
tmp.AvgUnitPrice
from Products P
left join 
	(
	select 
	P2.CategoryID,
	AVG(P2.UnitPrice) as AvgUnitPrice
	from Products P2
	group by
	P2.CategoryID
	) as tmp on tmp.CategoryID=P.CategoryID
where P.UnitPrice>tmp.AvgUnitPrice
order by P.UnitPrice

--cte

with cte(CategoryID, AvgUnitPrice) as 
(
select 
CategoryID,
AVG(UnitPrice)
from Products
group by
CategoryID
)

select
P.ProductID,
P.ProductName,
P.UnitPrice,
C.AvgUnitPrice
from Products P 
inner join cte C on C.CategoryID=P.CategoryID
where P.UnitPrice>C.AvgUnitPrice
order by 
P.UnitPrice

/*
Zadanie 2.
Korzystając z tabel Products oraz Order Details oraz konstrukcji CTE wyświetl wszystkie identyfikatory (Products.ProductID) 
i nazwy produktów (Products.ProductName), których maksymalna wartość zamówienia bez uwzględnienia zniżki (UnitPrice*Quantity) 
jest mniejsza od średniej w danej kategorii. Inaczej mówiąc – nie istnieje wartość zamówienia większa niż średnia w kategorii, 
do której należy dany Produkt.
Wynik posortuj rosnąco wg identyfikatora produktu.*/


with CategoryAvgOrder(CategoryID,AvgCategorzOrderValue) as 
(
select
P.CategoryID,
avg(O.Quantity*O.UnitPrice)
from [Order Details] as O
left join Products P on P.ProductID=O.ProductID
group by
P.CategoryID
),

ProductMaxOrder(ProductID, MaxProductOrderValue) as 
(
select
O.ProductID,
max(O.Quantity*O.UnitPrice)
from [Order Details] O
group by
O.ProductID
)

select
P.ProductID,
P.ProductName
from Products P
inner join CategoryAvgOrder A on A.CategoryID=P.CategoryID
inner join ProductMaxOrder M on M.ProductID=P.ProductID
where M.MaxProductOrderValue<A.AvgCategorzOrderValue
order by P.ProductID asc


/*
Zadanie 3.
Korzystając z tabeli Employees wyświetl identyfikator, imię oraz nazwisko pracownika wraz z identyfikatorem, 
imieniem i nazwiskiem jego przełożonego. Do znalezienia przełożonego danego pracowania użyj pola ReportsTo. 
Wyświetl wyniki dla poziomu hierarchii nie większego niż 1 (zaczynając od 0). Do wyniku dodaj kolumnę WhoIsThis, 
która przyjmie odpowiednie wartości dla danego poziomu:
 Level = 0 – Krzysiu Jarzyna ze Szczecina
 Level = 1 – Pan Żabka*/

use [Northwind]
go

with EmployeesRek(EmployeeID, FirstName, LastName, ChiefID, ChiefFirstName, ChiefLastName, Level) as 
(
--zakotwiczenie szefa
select
E.EmployeeID,
E.FirstName,
E.LastName,
E.ReportsTo,
CAST(NULL AS NVARCHAR(10)) AS ChiefFirstName,
CAST(NULL AS NVARCHAR(20)) AS ChiefLastName,
Level=0
from Employees E
where
E.ReportsTo is null
union all
select
E2.EmployeeID,
E2.FirstName,
E2.LastName,
ER.EmployeeID,
ER.FirstName,
ER.LastName,
Level=ER.Level+1
from Employees E2 join EmployeesRek ER ON E2.ReportsTo=ER.EmployeeID
)


select
*,
CASE 
	WHEN Level=0 THEN 'Krzysiu Jarzyna ze Szczecina'
	WHEN Level=1 THEN 'Pan Żabka'
	WHEN Level=2 THEN 'Świeżak'
END as Pozycja
from EmployeesRek


/*
Zadanie 5.
Wykorzystując CTE i rekurencje, zbuduj zapytanie pozwalające przedstawić ciąg Fibonacciego, który opisany jest wzorem (źródło: https://pl.wikipedia.org/wiki/Ci%C4%85g_Fibonacciego):
*/

with fibo(n,value_temp,value_prev) as 
(
select 1,1,0
union all
select n+1,f.value_temp+f.value_prev,value_temp
from fibo f
WHERE
n<4
)

select * from fibo
option (MAXRECURSION 5);

--Wiecej zadan z rekurencja!