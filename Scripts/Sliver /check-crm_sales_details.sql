-- checking date consistency
SELECT  *
  FROM [Warehouse_Project_Data].[Bronze].[crm_sales_details]
  WHERE [sls_order_dt] is null
        OR [sls_order_dt] <= 0
        OR [sls_order_dt] <19000101
        OR [sls_order_dt] > 20261231
        OR LEN([sls_order_dt]) != 8
-- CHECKING FOR INVALID DATE 
SELECT  *
  FROM [Warehouse_Project_Data].[Bronze].[crm_sales_details]
WHERE [sls_order_dt] > [sls_ship_dt] 
      OR [sls_order_dt] > [sls_due_dt] 
--CHEACKING FOR INCONSISTENCY IN CALCULATION  
SELECT 
  [sls_sales]
  ,[sls_quantity]
  ,ABS([sls_price])
FROM [Warehouse_Project_Data].[Bronze].[crm_sales_details]
WHERE [sls_sales] != [sls_quantity]*ABS([sls_price])
OR [sls_sales] IS NULL OR [sls_quantity] IS NULL OR [sls_price] IS NULL
OR [sls_sales] <= 0 OR [sls_quantity] <= 0 OR [sls_price] <= 0
ORDER BY   [sls_sales]
  ,[sls_quantity]
  ,[sls_price]

--insering cleaned Data in silver layer
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
