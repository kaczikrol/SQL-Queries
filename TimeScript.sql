---Przemyslaw Kaczmarek 20171120
--Script which generate fields neccesary for DIM_TABLE in DATA WAREHOUSE

IF OBJECT_ID(N'dbo.TimeDimension',N'TF') IS NOT NULL
DROP FUNCTION dbo.TimeDimension
GO

CREATE FUNCTION dbo.TimeDimension (@StartDate date,@StopDate date)
RETURNS @TimeTable TABLE
(
	--here update TABLE if you want add another columns
	ID				int identity(1,1) primary key,	-- it's have two functions first as a identificator and second more important - appriopriate order in table :)
	DATE			date,
	DAY				int,
	MONTH			int,
	QUARTER			int,
	YEAR			int,
	DAYOFYEAR		int,
	WEEKOFYEAR		int,
	WEEKDAY			int,
	DAYNAME			nvarchar(9),
	MONTHNAME		nvarchar(9),
	DAYSAGO			int,
	MONTHSAGO		int,						---it's calendary months from current months, not full months from today
	YEARSAGO		int,						---it's calendary years from current year, not full years from today
	YEARQUARTER		nvarchar(7),
	YEARMONTH		nvarchar(7)
)
AS

BEGIN

	--here update DECLARE after add columns
	DECLARE	@Date				date,
			@Day				int,
			@Month				int,
			@Quarter			int,
			@Year				int,
			@DayOfYear			int,
			@WeekOfYear			int,
			@WeekDay			int,
			@DayName			nvarchar(9),
			@MonthName			nvarchar(9),
			@DaysAgo			int,
			@MonthsAgo			int,
			@YearsAgo			int,
			@YearQuarter		nvarchar(7),
			@YearMonth			nvarchar(7),
			@QuarterC			nvarchar(2),
			@MonthC				nvarchar(2),
			@Diff				bigint

	--here update SET after add columns
	SET		@Date = @StartDate
	SET		@Day = DATEPART(DAY,@StartDate)
	SET		@Month = DATEPART(MONTH,@StartDate)
	SET		@Quarter = DATEPART(QUARTER,@StartDate)
	SET		@Year = DATEPART(YEAR,@StartDate)
	SET		@DayOfYear = DATEPART(DAYOFYEAR,@StartDate)
	SET		@WeekOfYear= DATEPART(WEEK,@StartDate)
	SET		@WeekDay = DATEPART(WEEKDAY,@StartDate)
	SET		@DayName = DATENAME(dw,@StartDate)
	SET		@MonthName = DATENAME(month,@StartDate)
	SET		@DaysAgo = DATEDIFF(DAY,@StartDate,GETDATE())
	SET		@MonthsAgo = DATEDIFF(MONTH,@StartDate,GETDATE())
	SET		@YearsAgo = DATEDIFF (YEAR,@StartDate,GETDATE())

	--here we create YYYY-QQ, this if statement is not necessary
	IF @Quarter<10 SET @QuarterC=CONCAT('0',@Quarter)
	ELSE SET @QuarterC=@Quarter
	SET		@YearQuarter = CONCAT(@Year,'-',@QuarterC)

	--here we create YYYY-MM
	IF @Month<10 SET @MonthC=CONCAT('0',@Month)
	ELSE SET @MonthC=@Month
	SET		@YearMonth = CONCAT (@Year, '-',@MonthC)
	SET		@Diff = DATEDIFF(DAY,@StartDate,@StopDate)

	WHILE @Diff>=0 
		BEGIN

		--here update INSERT after add columns
		INSERT	@TimeTable values (@Date,@Day,@Month,@Quarter,@Year,@DayOfYear,@WeekOfYear,@WeekDay,@DayName,@MonthName,@DaysAgo,@MonthsAgo,@YearsAgo,@YearQuarter,@YearMonth)

		--here update SET after add columns
		SET @Date = DATEADD(DAY,1,@Date)
		SET	@Day = DATEPART(DAY,@Date)
		SET	@Month = DATEPART(MONTH,@Date)
		SET @Quarter = DATEPART(QUARTER,@Date)
		SET	@Year = DATEPART(YEAR,@Date)
		SET @DayOfYear = DATEPART(DAYOFYEAR,@Date)
		SET @WeekOfYear = DATEPART(WEEK,@Date)
		SET	@WeekDay = DATEPART(WEEKDAY,@Date)
		SET @DayName = DATENAME(dw,@Date)
		SET	@MonthName = DATENAME (month, @Date)
		SET @DaysAgo = DATEDIFF(DAY, @Date, GETDATE())
		SET @MonthsAgo = DATEDIFF(MONTH,@Date,GETDATE())
		SET @YearsAgo = DATEDIFF(YEAR,@Date,GETDATE())


		IF @Quarter<10 SET @QuarterC=CONCAT('0',@Quarter)
		ELSE SET @QuarterC=@Quarter
		SET @YearQuarter = CONCAT(@Year,'-',@QuarterC)

		IF @Month<10 SET @MonthC=CONCAT('0',@Month)
		ELSE SET @MonthC=@Month
		SET @YearMonth = CONCAT(@Year,'-',@MonthC)

		--here is condidtion of stop clause while
		SET	@Diff = DATEDIFF(DAY,@Date,@StopDate)

		END;

RETURN

END;

GO

select * FROM dbo.TimeDimension('1950-01-01','2051-01-01') as Testy
GO
