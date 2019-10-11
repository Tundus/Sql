--Modifying Data

/*
Challenge 1: Inserting Products
Each Adventure Works product is stored in the SalesLT.
Product table, and each product has a unique ProductID identifier, which is implemented as an IDENTITY column 
in the SalesLT.Product table. Products are organized into categories, which are defined in the SalesLT.ProductCategory table. 
The products and product category records are related by a common ProductCategoryID identifier, 
which is an IDENTITY column in the SalesLT.ProductCategory table.
*/

/*1. Insert a product
Adventure Works has started selling the following new product. 
Insert it into the SalesLT.Product table, using default or NULL values for unspecified columns:

Name		|ProductNumber	|StandardCost	|ListPrice	|ProductCategoryID	|SellStartDate	|
LED Lights	|LT-L123		|2.56			|12.99		|37					|<Today>		|

After you have inserted the product, run a query to determine the ProductID that was generated. 
Then run a query to view the row for the product in the SalesLT.Product table.
*/

INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
	VALUES
	('LED Lights', 'LT-L123', 2.56, 12.99, 37, GETDATE())
	
SELECT SCOPE_IDENTITY() as ProductID

SELECT *
FROM SalesLT.Product
WHERE ProductID > 999

/*2. Insert a new category with two products
Adventure Works is adding a product category for ‘Bells and Horns’ to its catalog. 
The parent category for the new category is 4 (Accessories). This new category includes the following two new products:

Name			|ProductNumber	|StandardCost	|ListPrice	|ProductCategoryID					|SellStartDate	|
Bicycle Bell	|BB-RING		|2.47			|4.99		|<The new ID for Bells and Horns>	|<Today>		|
Bicycle Horn	|BB-PARP		|1.29			|3.75		|<The new ID for Bells and Horns>	|<Today>		|

Write a query to insert the new product category, and then insert the two new products with the appropriate ProductCategoryID value.
After you have inserted the products, query the SalesLT.Product and SalesLT.ProductCategory tables to verify that 
the data has been inserted.
*/

INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name)
	VALUES
	(4, 'Bells and Horns')

DECLARE @NewProdCat INT;	
SET @NewProdCat = (SELECT SCOPE_IDENTITY())

INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)

	VALUES
		('Bicycle Bell', 'BB-RING', 2.47, 4.99, @NewProdCat,GETDATE()),
		('Bicycle Horn', 'BB-PARP', 1.29, 3.75, @NewProdCat,GETDATE())
		
SELECT SCOPE_IDENTITY()

SELECT *
FROM SalesLT.ProductCategory
WHERE ProductCategoryID = 42

SELECT *
FROM SalesLT.Product
WHERE ProductID IN (1001, 1002)

/*Challange 2: Updating products
You have inserted data for a product, but the pricing details are not correct. 
You must now update the records you have previously inserted to reflect the correct pricing.
*/

/*1. Update product prices
The sales manager at Adventure Works has mandated a 10% price increase for all products in the Bells and Horns category. 
Update the rows in the SalesLT. Product table for these products to increase their price by 10%.
*/
UPDATE SalesLT.Product
	SET ListPrice = (ListPrice * 1.1)
WHERE ProductCategoryID = 42;

/*2. Discontinue products
The new LED lights you inserted in the previous challenge are to replace all previous light products. 
Update the SalesLT.Product table to set the DiscontinuedDate to today’s date for all products in the Lights category 
(Product Category ID 37) other than the LED Lights product you inserted previously.

*/
UPDATE SalesLT.Product
	SET DiscontinuedDate = GETDATE()
	WHERE ProductCategoryID = 37 AND ProductID != 1000;
	
SELECT *
FROM SalesLT.Product
WHERE ProductCategoryID = 37;

/*Challange 3: Deleting Products
The Bells and Horns category has not been successful, and it must be deleted from the database.
Delete the records foe the Bells and Horns category and its products. 
You must ensure that you delete the records from the tables in the correct order to avoid a foreign-key constraint violation.
*/

DELETE FROM SalesLT.Product
	WHERE ProductCategoryID = 42;

SELECT *
FROM SalesLT.Product
WHERE ProductCategoryID = 42;

DELETE FROM SalesLT.ProductCategory WHERE ProductCategoryID = 42;
	

SELECT *
FROM SalesLT.ProductCategory
WHERE ProductCategoryID = 42;

