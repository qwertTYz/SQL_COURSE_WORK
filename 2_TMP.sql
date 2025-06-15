CREATE TABLE tmp_countries (
  Country_Name TEXT
);

CREATE TABLE tmp_cities (
  City_Name TEXT,
  Country_Name TEXT
);

CREATE TABLE tmp_addresses (
  Address_Name TEXT,
  Postal_Code TEXT,
  City_Name TEXT
);

CREATE TABLE tmp_customers (
  First_Name TEXT,
  Last_Name TEXT,
  Gender TEXT,
  Email TEXT,
  Customer_Password TEXT,
  Phone_Number TEXT,
  Date_Of_Birth DATE,
  Member_Since DATE
);

CREATE TABLE tmp_orders (
  Customer_Email TEXT,
  Order_Status TEXT,
  Way_Of_Payment TEXT,
  Delivery_Address_Name TEXT,
  Start_Date DATE,
  End_Date DATE,
  Order_Sum NUMERIC(10,2)
);

CREATE TABLE tmp_manufacturers (
  Manufacturer_Name TEXT,
  Address_Name TEXT
);

CREATE TABLE tmp_brands (
  Brand_Name TEXT,
  Address_Name TEXT
);

CREATE TABLE tmp_categories (
  Category_Name TEXT,
  Category_Description TEXT
);

CREATE TABLE tmp_products (
  Product_Name TEXT,
  Product_Description TEXT,
  Unit_Price NUMERIC,
  Category_Name TEXT,
  Manufacturer_Name TEXT,
  Brand_Name TEXT
);

CREATE TABLE tmp_order_items (
  Order_Start_Date DATE,
  Customer_Email TEXT,
  Product_Name TEXT,
  Quantity INT
);
