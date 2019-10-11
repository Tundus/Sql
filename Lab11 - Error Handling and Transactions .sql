/*Challange 1: Logging Errors
You are implementing a Transact-SQL script to delete orders, and you want to handle any errors that
occur during the deletion process.*/

/*1. Throw an error for non-existant orders 
You are currently using the following code to delete order data

DECLARE @SalesOrderID as INT = <the_order_id_to_delete>
DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;
DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;

This code always succeeds, even when the specified order doesn't exist. Modify the code
to check for the existence of the specified order id before attempting to delete it. If the 
order doesn't exist, your code should throw an error. Otherwise, it should go ahead 
and delete the order data
*/

--For simplicity we start off with a variable that will be used as an identifier for
--sales orders to be deleted.
DECLARE @SalesOrderID as INT = 71817;

--Below I will use an IF statement to check for the existence of the above
--defined sales order. Check out how Exists works. Since we have 2 different
--tables to delete the orders from I cross join the two and check their joint
--rowset. I could have used a union too. Below I will use Try-Catch.
IF (EXISTS (SELECT sod.SalesOrderID, soh.SalesOrderID
			FROM SalesLT.SalesOrderDetail as sod
			CROSS JOIN
			SalesLT.SalesOrderHeader as soh
			WHERE	sod.SalesOrderID = @SalesOrderID
			OR		soh.SalesOrderID = @SalesOrderID))
				
				--I wanted to check the two delete operations as one unit.
				--If any of them fails I want to raise an error. I can't put up with
				--half way through solutions.
				BEGIN
					DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID
					DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID
				END;
--If above delete operation fails comes the below error message
ELSE 
	BEGIN
		RAISERROR('No such record exists!', 16, 0)
	END;
	-- If I were using a higher version of MS SQL Server
	-- (I am on 2008R2)I could have used this syntax:
	--(THROW 50001, 'No such record exists!', 0;)


/* 2. Handle Errors
Your code now throws an error if the specified order does not exist. You must now 
refine your code to catch this (or any other) error and print the error message to 
the user interface using the PRINT command.
*/ 

--I will use a variable to declare SalesOrderID that need be deleted. Also, I am
--including the whole in a Begin-End structure. You can start testing my code by
--deleting an existing order and when you successfully deleted related records
--rerun code to see if error is thrown as expected. Uncomment next line to spot
--an existing order.
--select * from SalesLT.SalesOrderDetail order by SalesOrderID

BEGIN
DECLARE @SalesOrderID1 as INT = 71938
BEGIN TRY
			--Uncomment following line to see that my code works for any other errors
			--SELECT 1/0

			DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID1
			DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID1
			
			--Delete won't error if no record matches its condition. We should know 
			--somehow that no record was deleted. Solution is to count the affected 
			--rows. If none was deleted an error will be raised that will be handled 
			--in Catch section. Notice that Print 'Success!' won't execute if nothing
			--was deleted. Error handling starts when RAISERROR is called.
			if @@ROWCOUNT=0
				RAISERROR ('No such record!',16,0)
				
			PRINT 'Success!'
			
END TRY
BEGIN CATCH

		--Make output readable add an empty line.
		PRINT ''
		--Error message
		RAISERROR('An ERROR OCCURED:', 16,0);
		--Acctual error. It could be the above user defined or else. Test it with 
		--uncommenting 1/0. Printing the actual error.
		PRINT ERROR_MESSAGE();
		
END CATCH
END;



/* Challenge 2: Ensuring Data Consistency
1. Implement a transaction
Enhance the code you created in the previous challenge so that the two DELETE statements are treated
as a single transactional unit of work. In the error handler, modify the code so that if a transaction is in
process, it is rolled back and the error is re-thrown to the client application. If not transaction is in
process the error handler should continue to simply print the error message.

To test your transaction, add a THROW statement between the two DELETE statements to simulate an
unexpected error. When testing with a valid, existing order ID, the error should be re-thrown by the
error handler and no rows should be deleted from either table. 
*/

--Check that the order exists in Order detail table. Use an existing order. Don't you worry
--delete transaction will be rolled back.
SELECT * FROM SalesLT.SalesOrderDetail ORDER BY SalesOrderID

BEGIN
DECLARE @SalesOrderID1 as INT = 71936
BEGIN TRY
			--We do 2 things below. Batch our two delete statements in a single
			--transaction called DEL1. Before we finish with the second delete
			--an error is raised to force error handling and transaction roll back.
			--If you remove (comment out) RAISERROR Orders will be deleted. 
			--Give it a go after testing first scenario. 
			BEGIN TRAN DEL1
				DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID1
				RAISERROR ('Delete transaction: DEL1 has failed!', 17, 0)
				DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID1
				COMMIT TRAN DEL1
				
			--Delete won't error if no record matches its condition. We should know 
			--somehow that no record was deleted. Solution is to count the affected 
			--rows. If none was deleted an error will be raised that will be handled 
			--in Catch section. Notice that Print 'Success!' won't execute if nothing
			--was deleted. Error handling starts when RAISERROR is called.
			if @@ROWCOUNT=0
				RAISERROR ('No such record!',16,0)
				
			PRINT 'Success!'
			
END TRY
BEGIN CATCH

		--Make output readable add an empty line.
		PRINT ''
		--Error message
		RAISERROR('An ERROR OCCURED:', 16,0);
		--Acctual error. It could be the above user defined or else.
		PRINT ERROR_MESSAGE();
		
		--I wanted to separate the case when the error is caused by
		--the need for rollback. I shouldn't have to since if there
		--was no error I could have leave the transaction rolled back
		--for whaterver reason (e.g. no record exists or else) but I wanted
		--it rolls back when my custom error occurs.
		IF ERROR_MESSAGE() = 'Delete transaction: DEL1 has failed!'
			BEGIN
				PRINT 'DEL1 will be rolled back!'
				ROLLBACK TRAN DEL1
			END;
		
END CATCH
END;