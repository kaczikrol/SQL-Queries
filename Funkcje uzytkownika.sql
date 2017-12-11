use Northwind
go 

--CREATING BACKUP
BACKUP DATABASE [Northwind]
TO DISK = 'E:\SQL Database\Backup\Northwind\Northwind.Bak'
	WITH FORMAT,
		MEDIANAME = 'Z_SQLServerBackups',
		NAME  = 'Backup of Northwind'
GO

-- User definied functions
use [NorthwindBackup]
go 

select * from [dbo].[Products]

/*
Stwórz funkcje ChangeUnitPrice, która zmienia cene danego produktu o x procent. Domyslnie 0%.
*/

IF OBJECT_ID (N'dbo.ChangeUnitPrice',N'FN') IS NOT NULL 
	DROP FUNCTION dbo.ChangeUnitPrice

GO

CREATE FUNCTION dbo.ChangeUnitPrice (@ProductID int, @PercentValueChange float = 0)
RETURNS money
AS
BEGIN
	DECLARE @NewUnitPrice money;
	DECLARE @OldUnitPrice money;
	SET @OldUnitPrice = (select UnitPrice from Products where ProductID=@ProductID);
	SET @NewUnitPrice = @OldUnitPrice*(1+@PercentValueChange)
	RETURN(round(@NewUnitPrice,2))
END;

GO

select * from Products where ProductID=1
UPDATE Products
SET UnitPrice=dbo.ChangeUnitPrice(1,0.12)
where ProductID=1
select * from Products where ProductID=1


/*
Stwórz funkcje która zwraca Produkty, których UnitPrice > x
*/

IF OBJECT_ID(N'dbo.FilterValue',N'IF') IS NOT NULL
	DROP FUNCTION dbo.FilterValue
GO

CREATE FUNCTION dbo.FilterValue (@Value money)
RETURNS TABLE 
AS 
RETURN
(
SELECT * FROM Products
WHERE UnitPrice>@Value
);
GO

SELECT * FROM FilterValue(24.21)
select * from Products where UnitPrice>24.21

/*
Stwórz funkcje generuj¹ca zestawienie Sprzeda¿y dedykowane dla okreœlonego przedzia³u czasowego oraz Sprzedawcy
*/

IF OBJECT_ID(N'dbo.SalesStatement',N'IF') IS NOT NULL
	DROP FUNCTION dbo.SalesStatement
GO

CREATE FUNCTION dbo.SalesStatement (@SalesFrom date, @SalesTo date, @SalesmanID int)
RETURNS TABLE
AS 
RETURN
(
SELECT
E.EmployeeID,
E.FirstName,
E.LastName,
E.ReportsTo,
E.Region,
E.Title,
COUNT(OD.OrderID) as Orders,
SUM(OD.Quantity*OD.UnitPrice) as OrdersValue,
O.OrderDate,
DATEPART(YEAR,O.OrderDate) AS OrderYear,
DATEPART(MONTH,O.OrderDate) AS OrderMonth,
DATEPART(DAY,O.OrderDate) AS OrderDay, 
O.ShipRegion
FROM [Order Details] OD 
join Orders O on OD.OrderID=O.OrderID
join Products P on P.ProductID=OD.ProductID
join Employees E on E.EmployeeID=O.EmployeeID
WHERE O.OrderDate >= @SalesFrom 
	AND O.OrderDate <= @SalesTo
	AND E.EmployeeID = @SalesmanID 
GROUP BY
E.EmployeeID,
E.FirstName,
E.LastName,
E.ReportsTo,
E.Region,
E.Title,
O.OrderDate,
DATEPART(YEAR,O.OrderDate),
DATEPART(MONTH,O.OrderDate),
DATEPART(DAY,O.OrderDate),
O.ShipRegion
);

GO

SELECT * FROM dbo.SalesStatement('1995-01-01','2014-01-02',7)

/*
Napisz funkcje placa netto, ktora dla podanej placy oraz stawki podatku zwroci wartoœæ p³acy netto
*/

IF OBJECT_ID(N'dbo.PlacaNetto',N'FN') is not null 
	DROP FUNCTION dbo.PlacaNetto
GO

CREATE FUNCTION dbo.PlacaNetto (@GrossValue money, @Tax float = 0)
RETURNS money 
AS
BEGIN
	RETURN(@GrossValue*(1-@Tax))
END;
GO

select dbo.PlacaNetto(6000,default) as NetValue

/*
Napisz funkcjê, która dla daty zatrudnienia pracownika wylicza sta¿ pracy w latach.
*/

IF OBJECT_ID(N'StazPracy',N'FN') IS NOT NULL
	DROP FUNCTION dbo.YearsOfWork
GO
CREATE FUNCTION dbo.YearsOfWork(@StartDate date)
RETURNS int
as
BEGIN
	DECLARE @Today date=GETDATE()
	DECLARE @DaysOfWork int
	DECLARE @YearsOfWork int
	SET @DaysOfWork = DATEDIFF(day,@StartDate,@Today)
	SET @YearsOfWork = round(@DaysOfWork / 360,0)
	RETURN (@YearsOfWork)
END;
GO
SELECT dbo.YearsOfWork('2016-01-11') as 'Sta¿ pracy'