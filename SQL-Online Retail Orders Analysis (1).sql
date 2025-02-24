/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/

-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]

SELECT 
    CONCAT(
        CASE 
            WHEN customer_gender = 'M' THEN 'MR.'
            WHEN customer_gender = 'F' THEN 'MS.'
            ELSE '' 
        END, ' ', 
        UPPER(customer_fname), ' ', 
        UPPER(customer_lname)
    ) AS full_name,
    customer_email AS email_id,
    customer_creation_date AS creation_date,
    CASE 
        WHEN EXTRACT(YEAR FROM customer_creation_date) < 2005 THEN 'A'
        WHEN EXTRACT(YEAR FROM customer_creation_date) BETWEEN 2005 AND 2010 THEN 'B'
        ELSE 'C'
    END AS customer_category
FROM 
    online_customer;




-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
    
SELECT 
    p.product_id,
    p.product_desc,
    p.product_quantity_avail,
    p.product_price,
    (p.product_quantity_avail * p.product_price) AS inventory_value,
    CASE 
        WHEN p.product_price > 20000 THEN p.product_price * 0.8  -- 20% discount
        WHEN p.product_price > 10000 THEN p.product_price * 0.85 -- 15% discount
        ELSE p.product_price * 0.9                               -- 10% discount
    END AS new_price
FROM 
    product p
LEFT JOIN 
    order_items oi ON p.product_id = oi.product_id
WHERE 
    oi.product_id IS NULL  -- Selects only products that have not been sold
ORDER BY 
    inventory_value DESC;  -- Sort by inventory value in descending order



-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
    
SELECT 
    pc.PRODUCT_CLASS_CODE,
    pc.PRODUCT_CLASS_DESC,
    COUNT(p.PRODUCT_ID) AS COUNT_OF_PRODUCT_TYPE,
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM 
    product p
JOIN 
    product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
GROUP BY 
    pc.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC
HAVING 
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) > 100000
ORDER BY 
    INVENTORY_VALUE DESC;


-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

SELECT 
    oc.CUSTOMER_ID,
    CONCAT(UPPER(oc.CUSTOMER_FNAME), ' ', UPPER(oc.CUSTOMER_LNAME)) AS FULL_NAME,
    oc.CUSTOMER_EMAIL,
    oc.CUSTOMER_PHONE,
    a.COUNTRY
FROM 
    online_customer oc
JOIN 
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE 
    oc.CUSTOMER_ID NOT IN (
        SELECT 
            o.CUSTOMER_ID
        FROM 
            order_header o
        WHERE 
            o.ORDER_STATUS != 'Cancelled' -- Exclude customers with non-cancelled orders
    )
ORDER BY 
    oc.CUSTOMER_ID;

        
-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    
SELECT 
    s.SHIPPER_NAME,
    a.CITY,
    COUNT(DISTINCT oc.CUSTOMER_ID) AS NUM_CUSTOMERS_CATERED,
    COUNT(oh.ORDER_ID) AS NUM_CONSIGNMENTS_DELIVERED
FROM 
    shipper s
JOIN 
    order_header oh ON s.SHIPPER_ID = oh.SHIPPER_ID
JOIN 
    online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN 
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE 
    s.SHIPPER_NAME = 'DHL' 
GROUP BY 
    s.SHIPPER_NAME, a.CITY
ORDER BY 
    a.CITY;


-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]

SELECT 
    oc.CUSTOMER_ID,
    CONCAT(UPPER(oc.CUSTOMER_FNAME), ' ', UPPER(oc.CUSTOMER_LNAME)) AS FULL_NAME,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
    SUM(oi.PRODUCT_QUANTITY * p.PRODUCT_PRICE) AS TOTAL_VALUE
FROM 
    online_customer oc
JOIN 
    order_header oh ON oc.CUSTOMER_ID = oh.CUSTOMER_ID
JOIN 
    order_items oi ON oh.ORDER_ID = oi.ORDER_ID
JOIN 
    product p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE 
    oh.PAYMENT_MODE = 'CASH' 
    AND oc.CUSTOMER_LNAME LIKE 'G%'
GROUP BY 
    oc.CUSTOMER_ID, oc.CUSTOMER_FNAME, oc.CUSTOMER_LNAME
ORDER BY 
    oc.CUSTOMER_ID;


    
-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    
SELECT 
    oi.ORDER_ID,
    SUM(p.LEN * p.WIDTH * p.HEIGHT * oi.PRODUCT_QUANTITY) AS TOTAL_VOLUME
FROM 
    order_items oi
JOIN 
    product p ON oi.PRODUCT_ID = p.PRODUCT_ID
JOIN 
    carton c ON c.CARTON_ID = 10
GROUP BY 
    oi.ORDER_ID
HAVING 
    SUM(p.LEN * p.WIDTH * p.HEIGHT * oi.PRODUCT_QUANTITY) <= (SELECT LEN * WIDTH * HEIGHT FROM carton WHERE CARTON_ID = 10)
ORDER BY 
    TOTAL_VOLUME DESC
LIMIT 1;


-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)

SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) AS QUANTITY_SOLD,
    CASE 
        WHEN COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) = 0 THEN 
            'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
        WHEN p.PRODUCT_CLASS_CODE IN (SELECT PRODUCT_CLASS_CODE FROM product_class WHERE PRODUCT_CLASS_DESC IN ('Electronics', 'Computers')) THEN 
            CASE 
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.1 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.5 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
        WHEN p.PRODUCT_CLASS_CODE IN (SELECT PRODUCT_CLASS_CODE FROM product_class WHERE PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches')) THEN 
            CASE 
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.2 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.6 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
        ELSE 
            CASE 
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.3 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.7 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
    END AS INVENTORY_STATUS
FROM 
    product p
LEFT JOIN 
    order_items oi ON p.PRODUCT_ID = oi.PRODUCT_ID
GROUP BY 
    p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, p.PRODUCT_CLASS_CODE
ORDER BY 
    p.PRODUCT_ID;

    
-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
    
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    SUM(oi.PRODUCT_QUANTITY) AS TOT_QTY
FROM 
    order_items oi
JOIN 
    product p ON oi.PRODUCT_ID = p.PRODUCT_ID
JOIN 
    order_header oh ON oi.ORDER_ID = oh.ORDER_ID
JOIN 
    online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN 
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE 
    oi.ORDER_ID IN (
        SELECT oi2.ORDER_ID
        FROM order_items oi2
        WHERE oi2.PRODUCT_ID = 201
    )
    AND a.CITY NOT IN ('Bangalore', 'New Delhi')
GROUP BY 
    p.PRODUCT_ID, p.PRODUCT_DESC
ORDER BY 
    TOT_QTY DESC;


-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
    
SELECT 
    oh.ORDER_ID,
    oh.CUSTOMER_ID,
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS FULL_NAME,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM 
    order_header oh
JOIN 
    online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN 
    order_items oi ON oh.ORDER_ID = oi.ORDER_ID
JOIN 
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE 
    oh.ORDER_ID % 2 = 0  -- Check for even ORDER_IDs
    AND a.PINCODE NOT LIKE '5%'  -- Pincode not starting with "5"
GROUP BY 
    oh.ORDER_ID, oh.CUSTOMER_ID, oc.CUSTOMER_FNAME, oc.CUSTOMER_LNAME
ORDER BY 
    oh.ORDER_ID;  -- Optional: to sort by ORDER_ID
