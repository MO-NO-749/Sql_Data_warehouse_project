/* ===============================================================================
	Stored Procedure: Load Silver Layer (Bronze -> Silver)
   ===============================================================================
	Script Purpose:
	This stored procedure performs the ETL (Extract, Transform, Load) process to populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
	- Inserts transformed and cleansed data from Bronze into Silver tables.
	Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.
	Usage Example:
	EXEC Silver.load silver;
*/

CREATE OR ALTER PROCEDURE Silver.Proceduer_load_Data_silver
 AS 
BEGIN 
	DECLARE @START_TIME DATETIME,@END_TIME DATETIME 
	BEGIN TRY
		-- USE TURNICATE IF FILE DATA IS DUPLICATAD 
		-- CONDITIONAL INSERT OR USEING NOT EXIST
	PRINT '==========================';
	PRINT 'Loading Data in Silver Layer ';
	PRINT '==========================';
		SET @START_TIME = GETDATE();
	PRINT '-------------------------------------';
	PRINT '>>LOADING DATA INTO Silver.crm_cust_info';
			-- INSERTING CLEANED DATA IN SILVER LAYER 
			 INSERT INTO  [Warehouse_Project_Data].[Silver].[crm_cust_info]
				  ([cst_id]
				  ,[cst_key]
				  ,[cst_firstname]
				  ,[cst_lastname]
				  ,[cst_marital_status]
				  ,[cst_gndr]
				  ,[cst_create_date]
			  )  
			-- CLEANING, EDITING AND CHANGING DATA BASED ON FINDING FROM 1ST 4 QUERYS   
			  SELECT 
			  cst_id
			  ,cst_key
			  ,TRIM(cst_firstname) AS cst_firstname 
			  ,TRIM(cst_lastname) AS cst_lastname
			  ,CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
					WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
					ELSE 'n/a'
					END AS  cst_marital_status
			  ,CASE WHEN cst_gndr = 'M' THEN 'Male'
					WHEN cst_gndr = 'F' THEN 'Female'
					ELSE 'n/a' 
					END AS cst_gndr
			  ,cst_create_date
			  FROM
			  (SELECT * ,
			  ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as valid_data 
			  FROM Bronze.crm_cust_info
			  )t
			  WHERE valid_data = 1 AND cst_id IS NOT NULL ;
		SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------';
	
	SET @START_TIME = GETDATE();
	PRINT '-------------------------------------'
	PRINT '>>LOADING DATA INTO Silver.crm_prd_info';
				INSERT INTO  [Warehouse_Project_Data].[Silver].[crm_prd_info]
				([prd_id]
					  ,cat_id
					  ,[prd_key]
					  ,[prd_nm]
					  ,[prd_cost]
					  ,[prd_line]
					  ,[prd_start_dt]
					  ,[prd_end_dt])
				SELECT 
				prd_id
				,REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id
				,REPLACE(SUBSTRING(prd_key, 7, LEN(prd_key)),'_','-') AS prd_key
				,prd_nm
				,COALESCE(prd_cost,0) AS prd_cost
				,CASE UPPER(TRIM(prd_line))
					  WHEN 'M' THEN 'Mountain'
					  WHEN 'R' THEN 'Road'
					  WHEN 'S' THEN 'Other Sales'
					  WHEN 'M' THEN 'Touring'
				 ELSE 'n/a' 
				 END AS prd_line
				,CAST(prd_start_dt AS DATE) AS prd_start_dt
				,CAST(CAST(LEAD(prd_start_dt) OVER (Partition BY prd_key order BY prd_start_dt) AS datetime)-1 AS DATE) AS prd_end_dt
				FROM bronze.crm_prd_info;
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'

	SET @START_TIME = GETDATE();
		PRINT '-------------------------------------'
		PRINT '>>LOADING DATA INTO Silver.crm_sales_details';
				INSERT INTO [Warehouse_Project_Data].[Silver].[crm_sales_details]
				([sls_ord_num]
					  ,[sls_prd_key]
					  ,[sls_cust_id]
					  ,[sls_order_dt]
					  ,[sls_ship_dt]
					  ,[sls_due_dt]
					  ,[sls_sales]
					  ,[sls_quantity]
					  ,[sls_price]
				)
				  SELECT  
					   [sls_ord_num]
					  ,[sls_prd_key]
					  ,[sls_cust_id]
					  ,CASE WHEN [sls_order_dt] = 0 OR LEN([sls_order_dt]) != 8 THEN NULL
						ELSE CAST(CAST([sls_order_dt] AS VARCHAR)AS DATE)
						END AS [sls_order_dt]
					  ,CASE WHEN [sls_ship_dt] = 0 OR LEN([sls_ship_dt]) != 8 THEN NULL
						 ELSE CAST(CAST([sls_ship_dt] AS VARCHAR)AS DATE)
						 END AS [sls_ship_dt]
					 ,CASE WHEN [sls_due_dt] = 0 OR LEN([sls_due_dt]) != 8 THEN NULL
						 ELSE CAST(CAST([sls_due_dt] AS VARCHAR)AS DATE)
						 END AS [sls_due_dt]
					  ,CASE WHEN [sls_sales] IS NULL 
						OR [sls_sales] <= 0 
						OR [sls_sales] != [sls_quantity] * ABS([sls_price])
						THEN [sls_quantity] * ABS([sls_price])
						ELSE [sls_sales]
						END AS [sls_sales]
					  ,[sls_quantity]
					  ,CASE WHEN [sls_price] IS NULL OR [sls_price] <= 0 
						THEN [sls_sales]/COALESCE([sls_quantity],0)
						ELSE [sls_price]
						END AS [sls_price] 
				  FROM [Warehouse_Project_Data].[Bronze].[crm_sales_details]
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'
	
	SET @START_TIME = GETDATE();
	PRINT '-------------------------------------'
		PRINT '>>LOADING DATA INTO Silver.erp_CUST_AZ12';
				-- INSERING CLEANED DATA IN Silver.erp_CUST_AZ12
				INSERT INTO [Warehouse_Project_Data].[Silver].[erp_CUST_AZ12]
				(      [CID]
					  ,[BDATE]
					  ,[GEN])
				 SELECT 
					   CASE WHEN [CID] LIKE 'NAS%' THEN SUBSTRING([CID],4,LEN([CID]))
							ELSE [CID]
							END AS [CID]
					  ,CASE WHEN [BDATE] > GETDATE() THEN NULL 
							ELSE [BDATE] 
							END AS [BDATE] 
					  ,CASE WHEN [GEN] = 'M' THEN 'Male'
							WHEN [GEN] = 'F' THEN 'Female'
							WHEN [GEN] = 'Male' THEN 'Male'
							WHEN [GEN] = 'Female' THEN 'Female'
							ELSE 'n/a'
							END AS [GEN]
				FROM [Warehouse_Project_Data].[Bronze].[erp_CUST_AZ12];
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'

	SET @START_TIME = GETDATE();
	PRINT '-------------------------------------'
	PRINT '>>LOADING DATA INTO Silver.erp_LOC_A101';										
					INSERT INTO [Warehouse_Project_Data].[Silver].[erp_LOC_A101]
						([CID]
						 ,[CNTRY])
					SELECT REPLACE([CID],'-','') AS [CID] 
						  ,CASE WHEN TRIM([CNTRY]) = 'DE' THEN 'Geramany'
								WHEN TRIM([CNTRY]) IN ('US', 'USA') THEN 'United States' 
								WHEN TRIM([CNTRY]) = '' OR [CNTRY] IS NULL THEN 'n/a'
								ELSE [CNTRY]
								END AS [CNTRY]
					FROM [Warehouse_Project_Data].[Bronze].[erp_LOC_A101]
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'
	
	SET @START_TIME = GETDATE();
		PRINT '-------------------------------------'
		PRINT '>>LOADING DATA INTO Silver.erp_PX_CAT_G1V2';
					INSERT INTO [Warehouse_Project_Data].[Silver].[erp_PX_CAT_G1V2] 
					 (     [ID]
						  ,[CAT]
						  ,[SUBCAT]
						  ,[MAINTENANCE]
					 )
					SELECT [ID]
						  ,[CAT]
						  ,[SUBCAT]
						  ,[MAINTENANCE]
					FROM [Warehouse_Project_Data].[Bronze].[erp_PX_CAT_G1V2] 
	SET @END_TIME = GETDATE();
	PRINT '>> LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + ' SECOUNDS';
	PRINT '-------------------------------------'

	END TRY
BEGIN CATCH 
	PRINT '=========================================';
	PRINT 'ERROR OCCURED DURING LOADING Silver LAYER' ;
	PRINT 'ERROR MESSAGE'+ ERROR_MESSAGE();
	PRINT 'ERROR MESSAGE'+ CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'ERROR MESSAGE'+ CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '========================================='
END CATCH
END
