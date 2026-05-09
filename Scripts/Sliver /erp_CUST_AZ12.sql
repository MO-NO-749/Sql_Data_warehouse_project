-- CHECKING OF KEYS THAT DON'T MATCH 
SELECT 
       [CID]
      ,[BDATE]
      ,[GEN]
  FROM [Warehouse_Project_Data].[Bronze].[erp_CUST_AZ12]
  WHERE [CID] NOT IN (SELECT cst_key FROM Silver.crm_cust_info) 

-- CHECKING FOR INCONSISTENCE BDATE
  SELECT
       [CID]
      ,[BDATE]
      ,[GEN]
  FROM [Warehouse_Project_Data].[Bronze].[erp_CUST_AZ12]
 WHERE [BDATE] < '1920-12-30' 
    OR [BDATE] > GETDATE() 
    OR [BDATE] IS NULL   
    
-- CHECKING FOR INCONSISTENCE GEN & NULLS
SELECT DISTINCT
      [GEN]
      ,CASE WHEN [GEN] = 'M' THEN 'Male'
            WHEN [GEN] = 'F' THEN 'Female'
            WHEN [GEN] = 'Male' THEN 'Male'
            WHEN [GEN] = 'Female' THEN 'Female'
            ELSE 'n/a'
            END AS [GEN]
  FROM [Warehouse_Project_Data].[Bronze].[erp_CUST_AZ12]

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
FROM [Warehouse_Project_Data].[Bronze].[erp_CUST_AZ12]
