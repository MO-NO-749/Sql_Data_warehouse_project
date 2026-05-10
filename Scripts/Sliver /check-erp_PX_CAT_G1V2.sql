SELECT *
  FROM [Warehouse_Project_Data].[Bronze].[erp_PX_CAT_G1V2]
  WHERE [CAT] != TRIM([CAT]) 
        OR [SUBCAT] != TRIM([SUBCAT])
        OR [MAINTENANCE] != TRIM([MAINTENANCE])

-- inserting cleaned data in silver layer        
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
