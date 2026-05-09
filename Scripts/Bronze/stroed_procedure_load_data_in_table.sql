/* STORED PROCEDURE FOR DATA LOAD IN BRONZE SCHEMA */
CREATE OR ALTER PROCEDURE Bronze.load_Data_Bronze
 AS 
BEGIN 
	DECLARE @START_TIME DATETIME,@END_TIME DATETIME 
	BEGIN TRY
		-- USE TURNICATE IF FILE DATA IS DUPLICATAD 
		-- CONDITIONAL INSERT OR USEING NOT EXIST
		PRINT '==========================';
		PRINT 'APPENDING CRM DATA ';
		PRINT '==========================';
	SET @START_TIME = GETDATE();
		PRINT '>> LOADING DATA INTO Bronze.crm_cust_info';
		BULK INSERT Bronze.crm_cust_info
		FROM 'E:\SQL_course\warehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK 
			);
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'
	SET @START_TIME = GETDATE();
		PRINT '>>LOADING DATA INTO Bronze.crm_prd_info';
		BULK INSERT Bronze.crm_prd_info
		FROM 'E:\SQL_course\warehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK 
			);
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'

	SET @START_TIME = GETDATE();
		PRINT '>>LOADING DATA INTO Bronze.crm_sales_details';
		BULK INSERT Bronze.crm_sales_details
		FROM 'E:\SQL_course\warehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK 
			);
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'
	
		PRINT '==========================';
		PRINT 'APPENDING ERP DATA';
		PRINT '==========================';
	SET @START_TIME = GETDATE();
		PRINT '>>LOADING DATA INTO Bronze.erp_CUST_AZ12';
		BULK INSERT Bronze.erp_CUST_AZ12
		FROM 'E:\SQL_course\warehouse\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK 
			); 
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'

	SET @START_TIME = GETDATE();
		PRINT '>>LOADING DATA INTO Bronze.erp_LOC_A101';										
		BULK INSERT Bronze.erp_LOC_A101
		FROM 'E:\SQL_course\warehouse\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK 
			);
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'
	
	SET @START_TIME = GETDATE();
		PRINT '>>LOADING DATA INTO Bronze.erp_PX_CAT_G1V2';
		BULK INSERT Bronze.erp_PX_CAT_G1V2
		FROM 'E:\SQL_course\warehouse\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK 
			);
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'

	END TRY
BEGIN CATCH 
	PRINT '=========================================';
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER' ;
	PRINT 'ERROR MESSAGE'+ ERROR_MESSAGE();
	PRINT 'ERROR MESSAGE'+ CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'ERROR MESSAGE'+ CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '========================================='
END CATCH
END
