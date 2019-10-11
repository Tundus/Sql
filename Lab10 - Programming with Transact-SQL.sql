/*You want to create reusable scripts that make it easy to insert sales orders. You plan to create a script to
insert the order header record, and a separate script to insert order detail records for a specified order
header. Both scripts will make use of variables to make them easy to reuse.*/



--Creating scripts to insert sales orders

/*

You want to create reusable scripts that make it easy to insert sales orders. You plan to create a script to
insert the order header record, and a separate script to insert order detail records for a specified order
header. Both scripts will make use of variables to make them easy to reuse.*/

/* 1. Write code to insert an order header

Your script to insert an order header must enable users to specify values for the order date, due date,
and customer ID. The SalesOrderID should be generated from the next value for the
SalesLT.SalesOrderNumber sequence and assigned to a variable. The script should then insert a record
into the SalesLT.SalesOrderHeader table using these values and a hard-coded value of ‘CARGO
TRANSPORT 5’ for the shipping method with default or NULL values for all other columns.
After the script has inserted the record, it should display the inserted SalesOrderID using the PRINT
command.

As in T-SQL 2008R2 Create Sequence is unavailable. I had to skip
that part of the task.
If it was working I'd create a sequence as follows*/
CREATE SEQUENCE SalesLT.SalesOrderNumber
	AS tinyint
	START WITH ((SELECT max(SalesLT.SalesOrderID) FROM SalesLT.SalesOrderDetail)+1)
	INCREMENT BY 1;
	
--and use it to get new values for inserted sales orders:
SET @SalesOrderSQ = NEXT VALUE FOR SalesLT.SalesOrderNumber

--If you have already created the stored procedure and want to 
--recreate it then use the below code to drop it first.
DROP PROCEDURE saleslt.InsertNewSalesOrderHeader

/*Apparently this is my solution less the sequence. Within I declare a variable
which gets the last value of the existing sales order sequence number increased
by one. This will mimic the sequence functionality I was missing being on 2008R2.
See details above.
*/
CREATE PROCEDURE saleslt.InsertNewSalesOrderHeader (@OrderDate AS Date, @DueDate AS Date, @CustomerID AS Int)
AS
DECLARE @SalesOrderSQ AS int = (SELECT MAX(SalesOrderID) from SalesLT.SalesOrderHeader)
SET @SalesOrderSQ +=  1
SET IDENTITY_INSERT saleslt.salesorderheader ON
INSERT INTO SalesLT.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, CustomerID, ShipMethod)
	VALUES (@SalesOrderSQ, @OrderDate, @DueDate, @CustomerID, 'CARGO TRANSPORT 5')

--Since we can't call store procedures using function results
--directly I had to use intermittent variables to do the job.  
Declare @OrDate Date, @DDate Date
	SET @OrDate = GETDATE()
	SET @DDate = GETDATE()+7;

--Eventually executing the code:
EXECUTE saleslt.InsertNewSalesOrderHeader @OrDate, @DDate, 1;

--Look up the result:
select * from SalesLT.SalesOrderHeader

--Delete result for rerunning or testing:
delete from SalesLTQ.salesorderheader
where ShipDate is null

--2. Write script to insert an order detail


--If you have already created the stored procedure and want to 
--recreate it then use the below code to drop it first.
DROP PROCEDURE saleslt.InsertSalesOrderDetail4ExistingSOH;

CREATE PROCEDURE SalesLT.InsertSalesOrderDetail4ExistingSOH (@SalesOrderID int, @ProductID int, @Quantity int, @UnitPrice int)
AS
	IF EXISTS(SELECT SalesOrderID FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID)
			INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice)
				VALUES (@SalesOrderID, @ProductID, @Quantity, @UnitPrice);
	ELSE
			PRINT 'The order does not exist!';
	
		
--Execute SP with params that will make it fail
EXECUTE SalesLT.InsertSalesOrderDetail4ExistingSOH 12345, 1, 1, 100;
--Executing the same SP with acceptable params
EXECUTE SalesLT.InsertSalesOrderDetail4ExistingSOH 71948, 836, 7, 199;

--Deleting created new records
DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = 71948;

/*Challenge 2: Updating bike prices
Adventure Works has determined that the market average price for a bike is $2000, and consumer
research has indicated that the maximum price any customer would likely to pay for a bike is $5000.
You must write some T-SQL logic that incrementally increases the list price for all bike products
by 10% until the average list price for a bike is at least the same as the market average, or until
the most expensive bike is priced above the acceptable macimum indicated by the consumer research.
*/
--If want to play around, recreate my Stored Procedure delete it first
drop procedure SalesLT.NewBikeAvgMaxPrice; 


--Here starts the stored procedure itself. A small improvement average, max price
--and iteration steps are parameters
CREATE PROCEDURE SalesLT.NewBikeAvgMaxPrice (@AveragePrice as money, @MaxPrice as money, @PriceIncrease as decimal(3,2))
AS
BEGIN
--As opposed to the requirement I am not touching the original table. I will muck with a global temp table
IF Exists (SELECT * FROM ##TmpAvgMaxPrice)
	DROP TABLE ##TmpAvgMaxPrice
--Let's create the global temp with data from a joined table. I am only interested in products 
--that are in category 'Bikes'. The join will filter them out of the SalesLT.Products table.
SELECT p.ProductID, p.Name, p. ProductNumber, p.Color, p.StandardCost, p.ListPrice, p.Size, p.Weight, p.ProductCategoryID, p.ProductModelID 
INTO ##TmpAvgMaxPrice
From SalesLT.Product as p
INNER JOIN SalesLT.vGetAllCategories as ac
ON p.ProductCategoryID = ac.ProductCategoryID
where ac.ParentProductCategoryName IN ('Bikes')
	--Again a small improvement over original requirements. I will stop increasing the listprice
	--before average or max exceeds the predefined levels. I am using script parameters as input.
	--The smaller @PriceIncrease value the closer we get to @AveragePrice, @MaxPrice
	WHILE	(Select AVG(listprice) from ##TmpAvgMaxPrice) * @PriceIncrease < @AveragePrice OR 
			(select MAX(listprice) from ##TmpAvgMaxPrice) * @PriceIncrease <= @MaxPrice
			UPDATE ##TmpAvgMaxPrice
			SET listprice = listprice * @PriceIncrease
END;
		
			
--Test the script			
EXECUTE SalesLT.NewBikeAvgMaxPrice 2000, 5000, 1.01

--Check the individual results
select * from ##TmpAvgMaxPrice

--Read my code back from your db
sp_helptext 'SalesLT.NewBikeAvgMaxPrice'