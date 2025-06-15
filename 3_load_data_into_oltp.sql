TRUNCATE tmp_countries;
\copy tmp_countries FROM 'countries.csv' WITH (FORMAT csv, HEADER);

INSERT INTO Countries (Country_Name)
SELECT DISTINCT Country_Name
  FROM tmp_countries
ON CONFLICT (Country_Name) DO NOTHING;


TRUNCATE tmp_cities;
\copy tmp_cities FROM 'cities.csv' WITH (FORMAT csv, HEADER);

INSERT INTO Cities (City_Name, City_Country_ID)
SELECT
  tmp.City_Name,
  c.Country_ID
FROM tmp_cities tmp
JOIN Countries c
  ON c.Country_Name = tmp.Country_Name
ON CONFLICT (City_Name, City_Country_ID) DO NOTHING;


TRUNCATE tmp_addresses;
\copy tmp_addresses FROM 'addresses.csv' WITH (FORMAT csv, HEADER);


INSERT INTO Addresses (Address_Name, Postal_Code, Address_City_ID)
SELECT
  tmp.Address_Name,
  tmp.Postal_Code,
  city.City_ID
FROM tmp_addresses tmp
JOIN Cities city
  ON city.City_Name = tmp.City_Name
JOIN Countries ctr
  ON ctr.Country_ID = city.City_Country_ID
  AND ctr.Country_Name = (
    SELECT Country_Name
      FROM tmp_cities
     WHERE City_Name = tmp.City_Name
     LIMIT 1
  )
ON CONFLICT ON CONSTRAINT addresses_name_city_unique DO NOTHING;


TRUNCATE tmp_customers;
\copy tmp_customers FROM 'customers.csv' WITH (FORMAT csv, HEADER);

INSERT INTO Customers
  (First_Name, Last_Name, Gender, Email, Customer_Password, Phone_Number, Date_Of_Birth, Member_Since)
SELECT
  tmp.First_Name,
  tmp.Last_Name,
  tmp.Gender,
  tmp.Email,
  tmp.Customer_Password,
  tmp.Phone_Number,
  tmp.Date_Of_Birth,
  tmp.Member_Since
FROM tmp_customers tmp
ON CONFLICT (Email) DO NOTHING;


TRUNCATE tmp_manufacturers;
\copy tmp_manufacturers FROM 'manufacturers.csv' WITH (FORMAT csv, HEADER);

INSERT INTO Manufacturers (Manufacturer_Name, Manufacturer_Address_ID)
SELECT
  tmp.Manufacturer_Name,
  a.Address_ID
FROM tmp_manufacturers tmp
JOIN Addresses a
  ON a.Address_Name = tmp.Address_Name
  AND a.Postal_Code = (
    SELECT Postal_Code FROM tmp_addresses WHERE Address_Name = tmp.Address_Name LIMIT 1
  )
ON CONFLICT ON CONSTRAINT manufacturers_manufacturer_name_key DO NOTHING;


TRUNCATE tmp_brands;
\copy tmp_brands FROM 'brands.csv' WITH (FORMAT csv, HEADER);

INSERT INTO Brands (Brand_Name, Brand_Address_ID)
SELECT
  tmp.Brand_Name,
  a.Address_ID
FROM tmp_brands tmp
JOIN Addresses a
  ON a.Address_Name = tmp.Address_Name
  AND a.Postal_Code = (
    SELECT Postal_Code FROM tmp_addresses WHERE Address_Name = tmp.Address_Name LIMIT 1
  )
ON CONFLICT (Brand_Name) DO NOTHING;


TRUNCATE tmp_categories;
\copy tmp_categories FROM 'categories.csv' WITH (FORMAT csv, HEADER);

INSERT INTO Categories (Category_Name, Category_Description)
SELECT
  tmp.Category_Name,
  tmp.Category_Description
FROM tmp_categories tmp
ON CONFLICT (Category_Name) DO NOTHING;


TRUNCATE tmp_products;
\copy tmp_products FROM 'products.csv' WITH (FORMAT csv, HEADER);

INSERT INTO Products
  (Product_Category_ID, Product_Name, Product_Description, Unit_Price, Product_Manufacturer_ID, Product_Brand_ID)
SELECT
  cat.Category_ID,
  tmp.Product_Name,
  tmp.Product_Description,
  tmp.Unit_Price,
  m.Manufacturer_ID,
  b.Brand_ID
FROM tmp_products tmp
JOIN Categories cat
  ON cat.Category_Name = tmp.Category_Name
JOIN Manufacturers m
  ON m.Manufacturer_Name = tmp.Manufacturer_Name
JOIN Brands b
  ON b.Brand_Name = tmp.Brand_Name
WHERE NOT EXISTS (
  SELECT 1
    FROM Products p
   WHERE p.Product_Name            = tmp.Product_Name
     AND p.Product_Description     = tmp.Product_Description
     AND p.Unit_Price              = tmp.Unit_Price
     AND p.Product_Manufacturer_ID = m.Manufacturer_ID
     AND p.Product_Brand_ID        = b.Brand_ID
);


TRUNCATE tmp_orders;
\copy tmp_orders FROM 'orders.csv' WITH (FORMAT csv, HEADER);

--INSERT INTO Orders
--  (Order_Customer_ID,
--   Order_Status,
--   Way_Of_Payment,
--   Delivery_Address_ID,
--   Start_Date,
--   End_Date,
--   Order_Sum)
--SELECT
--  cust.Customer_ID,
----tmp.Order_Status,
----tmp.Way_Of_Payment,  
--  LOWER(tmp.order_status)   AS order_status,
--  LOWER(tmp.way_of_payment) AS way_of_payment,
--  addr.Address_ID,
--  tmp.Start_Date,
--  tmp.End_Date,
--  tmp.Order_Sum
--FROM tmp_orders tmp
--JOIN Customers cust
--  ON cust.Email = tmp.Customer_Email
--JOIN Addresses addr
--  ON addr.Address_Name = tmp.Delivery_Address_Name
--WHERE NOT EXISTS (
--  SELECT 1
--    FROM Orders o
--   WHERE o.Order_Customer_ID   = cust.Customer_ID
--     AND o.Order_Status        = LOWER(tmp.Order_Status)
--     AND o.Way_Of_Payment      = LOWER(tmp.Way_Of_Payment)
--     AND o.Delivery_Address_ID = addr.Address_ID
--     AND o.Start_Date          = tmp.Start_Date
--     AND o.End_Date            = tmp.End_Date
--     AND o.Order_Sum           = tmp.Order_Sum
--);


INSERT INTO Orders
  (Order_Customer_ID,
   Order_Status,
   Way_Of_Payment,
   Delivery_Address_ID,
   Start_Date,
   End_Date,
   Order_Sum)
SELECT
  cust.Customer_ID,
--tmp.Order_Status,
--tmp.Way_Of_Payment,  
  LOWER(tmp.order_status)   AS order_status,
  LOWER(tmp.way_of_payment) AS way_of_payment,
  addr.Address_ID,
  tmp.Start_Date,
  tmp.End_Date,
  tmp.Order_Sum
FROM tmp_orders tmp
JOIN Customers cust
  ON cust.Email = tmp.Customer_Email
JOIN Addresses addr
  ON addr.Address_Name = tmp.Delivery_Address_Name
ON CONFLICT ON CONSTRAINT uq_orders_natural DO NOTHING;


TRUNCATE tmp_order_items;
\copy tmp_order_items FROM 'order_items.csv' WITH (FORMAT csv, HEADER);

INSERT INTO Order_Items
  (Order_Items_Order_ID, Order_Items_Product_ID, Quantity)
SELECT
  o.Order_ID,
  p.Product_ID,
  tmp.Quantity
FROM tmp_order_items tmp
JOIN Customers cust
  ON cust.Email = tmp.Customer_Email
JOIN Orders o
  ON o.Order_Customer_ID = cust.Customer_ID
 AND o.Start_Date        = tmp.Order_Start_Date
JOIN Addresses addr           				-- remove this address join?
ON addr.Address_ID = o.Delivery_Address_ID
JOIN Products p
  ON p.Product_Name = tmp.Product_Name
WHERE NOT EXISTS (
  SELECT 1
    FROM Order_Items oi
   WHERE oi.Order_Items_Order_ID   = o.Order_ID
     AND oi.Order_Items_Product_ID = p.Product_ID
     AND oi.Quantity               = tmp.Quantity
);