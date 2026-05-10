CREATE VIEW Gold.fact_sales AS
SELECT 
        sd.sls_ord_num AS order_number
      ,p.product_key AS product_key
      ,c.customer_key AS customer_key
      ,sd.sls_order_dt AS order_date
      ,sd.sls_ship_dt AS ship_date
      ,sd.sls_due_dt AS due_date
      ,sd.sls_quantity AS quantity
      ,sd.sls_price AS price
      ,sd.sls_sales AS sales_amount
  FROM Silver.crm_sales_details sd
  LEFT JOIN Gold.dim_customers c
  ON sd.sls_cust_id = c.customer_id
 LEFT JOIN Gold.dim_products p
  ON sd.sls_prd_key = p.product_number


CREATE VIEW Gold.dim_customers AS
SELECT 
        ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key 
      ,ci.cst_id AS customer_id 
      ,ci.cst_key AS customer_number
      ,ci.cst_firstname AS first_name
      ,ci.cst_lastname AS last_name
      ,CASE WHEN ci.cst_gndr = 'n/a' THEN COALESCE(ca.GEN, 'n/a')
            ELSE ci.cst_gndr 
            END
            AS gender
      ,ci.cst_marital_status AS marital_status
      ,lo.CNTRY AS country      
      ,ca.BDATE AS birth_date   
      ,ci.cst_create_date AS create_date
  FROM Silver.crm_cust_info ci
  LEFT JOIN Silver.erp_CUST_AZ12 ca
  ON        ci.cst_key = ca.CID
  LEFT JOIN Silver.erp_LOC_A101 lo
  ON        ci.cst_key = lo.CID
  
 
 

 -- checking consistency 
  SELECT distinct
      ci.cst_gndr
      ,ca.GEN
      ,CASE WHEN ci.cst_gndr = 'n/a' THEN COALESCE(ca.GEN, 'n/a')
            ELSE ci.cst_gndr 
            END
            AS Gender
  FROM Silver.crm_cust_info ci
  LEFT JOIN Silver.erp_CUST_AZ12 ca
  ON        ci.cst_key = ca.CID
  LEFT JOIN Silver.erp_LOC_A101 lo
  ON        ci.cst_key = lo.CID
  ORDER BY 1,2


CREATE VIEW Gold.dim_products AS
SELECT 
        ROW_NUMBER() OVER (ORDER BY pd.prd_start_dt,pd.prd_key) AS product_key
      ,pd.prd_id AS product_id 
      ,pd.prd_key AS product_number
      ,pd.prd_nm AS product_name 
      ,pd.cat_id AS product_catagory_id
      ,sb.CAT AS product_catagory
      ,sb.SUBCAT AS Product_subcatagory
      ,sb.MAINTENANCE AS product_maintenence
      ,pd.prd_cost AS product_cost
      ,pd.prd_line AS product_line
      ,pd.prd_start_dt AS product_start_date
  FROM Silver.crm_prd_info pd
  LEFT JOIN Silver.erp_PX_CAT_G1V2 sb
  ON      CAST(pd.cat_id AS VARCHAR) = CAST(sb.ID AS VARCHAR)
  WHERE pd.prd_end_dt IS NULL -- filter out historical data
