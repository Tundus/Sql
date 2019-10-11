/*Challenge 1: Retrieve Regional Sales Totals
Adventure Works sells products to customers in multiple country/regions around the world.

An existing report uses the following query to return total sales revenue grouped by country/region and
state/province.

*/

SELECT a.CountryRegion, a.StateProvince, SUM(soh.totaldue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON c.CustomerID = ca.CustomerID
INNER JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY a.CountryRegion, a.StateProvince
ORDER BY a.CountryRegion, a.StateProvince;


/*1. Retrieve totals for country/region and state/province
You have been asked to modify this query so that the results include a grand total for all sales revenue
and a subtotal for each country/region in addition to the state/province subtotals that are already
returned.
*/

SELECT	
		a.CountryRegion, 
		a.StateProvince, 
		SUM(soh.totaldue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON c.CustomerID = ca.CustomerID
INNER JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY 
GROUPING sets(a.CountryRegion, a.StateProvince, ())
ORDER BY a.CountryRegion DESC, a.StateProvince DESC;

/*2. Indicate the grouping level in the results
Modify your query to include a column named Level that indicates at which level in the total,
country/region, and state/province hierarchy the revenue figure in the row is aggregated. For example,
the grand total row should contain the value ‘Total’, the row showing the subtotal for United States
should contain the value ‘United States Subtotal’, and the row showing the subtotal for California should
contain the value ‘California Subtotal’.
*/
SELECT	
		CASE
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND 	GROUPING_ID(a.StateProvince) = 1 THEN 'Total'
			WHEN GROUPING_ID(a.CountryRegion) = 0 AND 	GROUPING_ID(a.StateProvince) = 1 THEN a.CountryRegion + ' Subtotal'
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND 	GROUPING_ID(a.StateProvince) = 0 THEN a.StateProvince + ' Subtotal'
		END AS 'LEVEL',
		a.CountryRegion, 
		a.StateProvince, 
		SUM(soh.totaldue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON c.CustomerID = ca.CustomerID
INNER JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY 
GROUPING sets(a.CountryRegion, a.StateProvince, ())
ORDER BY a.CountryRegion DESC, a.StateProvince DESC;

--3. Extend your query to include a grouping for individual cities
--3a. Add a grouping level for cities using GROUPING SET

SELECT	
		CASE
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 1 AND GROUPING_ID(a.city) = 1 THEN 'Total'
			WHEN GROUPING_ID(a.CountryRegion) = 0 AND GROUPING_ID(a.StateProvince) = 1 AND GROUPING_ID(a.city) = 1 THEN a.CountryRegion + ' Subtotal'
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 0 AND GROUPING_ID(a.city) = 1 THEN a.StateProvince + ' Subtotal'
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 1 AND GROUPING_ID(a.city) = 0 THEN a.City + ' Subtotal'
		
		END AS 'LEVEL',
		GROUPING_ID(a.city) AS CITY_GRPID, GROUPING_ID(a.StateProvince) AS STATE_GRPID, GROUPING_ID(a.CountryRegion) AS CTRY_GRPID,
		a.CountryRegion, 
		a.StateProvince, 
		a.City,
		SUM(soh.totaldue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON c.CustomerID = ca.CustomerID
INNER JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY 
GROUPING sets(a.CountryRegion, a.StateProvince, a.city, ())
ORDER BY a.CountryRegion DESC, a.StateProvince DESC, a.City DESC;

--3b. Add a grouping level for cities using ROLLUP
SELECT	
		CASE
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 1 AND GROUPING_ID(a.city) = 1 THEN 'Total'
			WHEN GROUPING_ID(a.CountryRegion) = 0 AND GROUPING_ID(a.StateProvince) = 1 AND GROUPING_ID(a.city) = 1 THEN a.CountryRegion + ' Subtotal'
			WHEN GROUPING_ID(a.CountryRegion) = 0 AND GROUPING_ID(a.StateProvince) = 0 AND GROUPING_ID(a.city) = 1 THEN a.StateProvince + ' Subtotal'
			WHEN GROUPING_ID(a.CountryRegion) = 0 AND GROUPING_ID(a.StateProvince) = 0 AND GROUPING_ID(a.city) = 0 THEN a.City + ' total'
		
		END AS 'LEVEL',
		GROUPING_ID(a.CountryRegion) AS CTRY_GRPID, GROUPING_ID(a.StateProvince) AS STATE_GRPID, GROUPING_ID(a.city) AS CITY_GRPID,
		a.CountryRegion, 
		a.StateProvince, 
		a.City,
		SUM(soh.totaldue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON c.CustomerID = ca.CustomerID
INNER JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY rollup(a.CountryRegion, a.StateProvince, a.city)
ORDER BY CTRY_GRPID DESC, STATE_GRPID DESC, CITY_GRPID DESC;

--3c. Add a grouping level for cities using CUBE
SELECT	
		CASE
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 1 AND GROUPING_ID(a.city) = 1 THEN 'Total'
			WHEN GROUPING_ID(a.CountryRegion) = 0 AND GROUPING_ID(a.StateProvince) = 1 AND GROUPING_ID(a.city) = 1 THEN a.CountryRegion + ' Subtotal'
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 0 AND GROUPING_ID(a.city) = 1 THEN a.StateProvince + ' Subtotal'
			WHEN GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 1 AND GROUPING_ID(a.city) = 0 THEN a.City + ' total'
		
		END AS 'LEVEL',
		GROUPING_ID(a.CountryRegion) AS CTRY_GRPID, GROUPING_ID(a.StateProvince) AS STATE_GRPID, GROUPING_ID(a.city) AS CITY_GRPID,
		a.CountryRegion, 
		a.StateProvince, 
		a.City,
		SUM(soh.totaldue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON c.CustomerID = ca.CustomerID
INNER JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY cube(a.CountryRegion, a.StateProvince, a.city)
ORDER BY CTRY_GRPID DESC, STATE_GRPID DESC, CITY_GRPID DESC;



/*Challenge 2
Adventure Works products are grouped into categories, which in turn have parent categories (defined in
the SalesLT.vGetAllCategories view). Adventure Works customers are retail companies, and they may
place orders for products of any category. The revenue for each product in an order is recorded as the
LineTotal value in the SalesLT.SalesOrderDetail table.
*/

/*1. Retrieve customer sales revenue for each parent category
Retrieve a list of customer company names together with their total revenue for each parent category in
Accessories, Bikes, Clothing, and Components.

Ami fontos a PIVOT-nal, hogy az inner query altal visszaadott oszlopokkal
dolgozhatunk a PIVOT-ban, illetve a vegso eredmenyben. Az alabbi peldaban
a CompanyName benne van az inner queryben, mert azt nem hasznaljuk a PIVOT-ban
, de azt akarjuk, hogy az legyen a sorokban. A LineTotal es a ParentProductCategoryName
mindketto pivotalva lesz. A LineTotal-okat fogjuk osszegezni es
a ParentProductCategoryName-ek lesznek az oszlop nevek. Ha tobb dolgot
szedunk ki az inner query-bol, akkor a dolog elkezd rosszul mukodni!
*/

SELECT CompanyName, pvt.Accessories, pvt.Bikes, pvt.Clothing, pvt.Components
FROM
(	SELECT c.CompanyName, sod.LineTotal, ac.ParentProductCategoryName
	FROM SalesLT.SalesOrderDetail as sod
	INNER JOIN SalesLT.SalesOrderHeader as soh
	ON sod.SalesOrderID = soh.SalesOrderID
	INNER JOIN SalesLT.Customer as c
	ON soh.CustomerID = c.CustomerID
	INNER JOIN SalesLT.Product as p
	ON sod.ProductID = p.ProductID
	INNER JOIN SalesLT.vGetAllCategories as ac
	ON p.ProductCategoryID = ac.ProductCategoryID) as iq
PIVOT 
(SUM(iq.linetotal) for iq.parentproductcategoryname in ([Accessories], [Clothing], [Bikes], [Components])) as pvt
ORDER BY CompanyName

SELECT c.CompanyName, soh.TotalDue
FROM SalesLT.SalesOrderHeader as soh
INNER JOIN SalesLT.Customer as c
ON soh.CustomerID = c.CustomerID

SELECT *
FROM SalesLT.Product

SELECT *
FROM SalesLT.vGetAllCategories