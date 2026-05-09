-- CHECKING WITH CONNECTING TABLE 
SELECT [CID]
      ,[CNTRY]
  FROM [Warehouse_Project_Data].[Bronze].[erp_LOC_A101]
where [CID] not in 
(SELECT cst_key FROM [Warehouse_Project_Data].[Silver].[crm_cust_info])

-- CHECKING consistency of CNTRY 
SELECT DISTINCT [CNTRY]
  FROM [Warehouse_Project_Data].[Bronze].[erp_LOC_A101]

-- INSERTING CLEANED DATA IN SILVER LAYER 
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
