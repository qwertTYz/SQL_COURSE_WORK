create table Customers 
(
    Customer_ID SERIAL PRIMARY KEY,
    First_Name TEXT NOT NULL,
    Last_Name TEXT NOT NULL,
    Gender TEXT CHECK (Gender IN ('male','female','not specified')),
    Email TEXT NOT NULL UNIQUE,
    Customer_Password TEXT NOT NULL,
    Phone_Number TEXT UNIQUE,
    Date_Of_Birth DATE NOT NULL,
    Member_Since DATE NOT NULL
      DEFAULT CURRENT_DATE
      CHECK (
        Member_Since >= DATE '1994-01-01'
        AND Member_Since <= CURRENT_DATE
        AND Member_Since > Date_Of_Birth
      )
);



CREATE OR REPLACE FUNCTION normalize_customer_fields()
RETURNS TRIGGER AS $$
BEGIN

	NEW.Gender := LOWER(NEW.Gender);	
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalize_customer_fields
BEFORE INSERT OR UPDATE ON Customers
FOR EACH ROW
EXECUTE FUNCTION normalize_customer_fields();




create table Addresses
(
	Address_ID SERIAL NOT NULL PRIMARY KEY,
	Address_Name TEXT NOT NULL UNIQUE,
	Postal_Code TEXT NOT NULL UNIQUE
);

create table Cities
(
	City_ID SERIAL NOT NULL PRIMARY KEY,
	City_Name TEXT NOT NULL
);

create table Countries
(
	Country_ID SERIAL NOT NULL PRIMARY KEY,
	Country_Name TEXT NOT NULL UNIQUE
);

alter table Cities
add column City_Country_ID INT NOT NULL REFERENCES Countries(Country_ID);

ALTER TABLE Cities
  ADD CONSTRAINT uq_city_per_country UNIQUE (City_Name, City_Country_ID);

alter table Addresses
add column Address_City_ID INT NOT NULL REFERENCES Cities(City_ID);

ALTER TABLE Addresses ADD CONSTRAINT addresses_name_city_unique
  UNIQUE(address_name, address_city_id);


create table Manufacturers
(
	Manufacturer_ID SERIAL NOT NULL PRIMARY KEY,
	Manufacturer_Name TEXT NOT NULL UNIQUE,
	Manufacturer_Address_ID INT NOT NULL REFERENCES Addresses(Address_ID)
);

create table Brands
(
	Brand_ID SERIAL NOT NULL PRIMARY KEY,
	Brand_Name TEXT NOT NULL UNIQUE,
	Brand_Address_ID INT NOT NULL REFERENCES Addresses(Address_ID)
);


create table Orders
(
	Order_ID SERIAL NOT NULL PRIMARY KEY,
	Order_Customer_ID INT REFERENCES Customers(Customer_ID),
	Order_Status TEXT NOT NULL CHECK (Order_Status IN ('basket', 'completed', 'cancelled', 'submitted', 'approved', 'in progress', 'delivered')),
	Way_Of_Payment TEXT NOT NULL CHECK (Way_Of_Payment IN ('cash', 'card', 'bank transfer')),
	Delivery_Address_ID INT NOT NULL REFERENCES Addresses(Address_ID),
	Start_Date DATE NOT NULL CHECK (Start_Date >= DATE '1994-01-01'),
	End_Date DATE CHECK (End_Date <= CURRENT_DATE AND end_date >= start_date),
	Order_Sum NUMERIC(10,2) DEFAULT 0 CHECK (Order_Sum >= 0)
);



ALTER TABLE Orders
  ADD CONSTRAINT uq_orders_natural UNIQUE (
    Order_Customer_ID,
    Order_Status,
    Way_Of_Payment,
    Delivery_Address_ID,
    Start_Date,
    End_Date,
    Order_Sum
  );


create table Categories
(
	Category_ID SERIAL NOT NULL PRIMARY KEY,
	Category_Name TEXT NOT NULL UNIQUE,
	Category_Description TEXT
);

create table Products
(
	Product_ID SERIAL NOT NULL PRIMARY KEY,
	Product_Category_ID INT NOT NULL REFERENCES Categories(Category_ID),
	Product_Name TEXT,
	Product_Description TEXT,
	Unit_Price NUMERIC(10,2) NOT NULL CHECK (Unit_Price > 0),
	Product_Manufacturer_ID INT NOT NULL REFERENCES Manufacturers(Manufacturer_ID),
	Product_Brand_ID INT  NOT NULL REFERENCES Brands(Brand_ID)	
);

create table Order_Items
(
	Order_Item_ID SERIAL PRIMARY KEY,
	Order_Items_Order_ID INT NOT NULL REFERENCES Orders(Order_ID),
	Order_Items_Product_ID INT NOT NULL REFERENCES Products(Product_ID),
	Quantity INT NOT NULL CHECK (Quantity > 0)
);
 
 
CREATE OR REPLACE FUNCTION normalize_order_fields()
RETURNS TRIGGER AS $$
BEGIN

	NEW.Order_Status := LOWER(NEW.Order_Status);
	NEW.Way_Of_Payment := LOWER(NEW.Way_Of_Payment);
	
	IF NEW.Order_Status NOT IN ('completed', 'cancelled') THEN
		NEW.End_Date := NULL;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalize_order_fields
BEFORE INSERT OR UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION normalize_order_fields(); 
 
 
 
 
--CREATE OR REPLACE FUNCTION recalculate_order_sum()
--  RETURNS TRIGGER
--  LANGUAGE plpgsql
--AS $$
--BEGIN
--  UPDATE Orders
--     SET order_sum = (
--       SELECT SUM(oi.quantity * p.unit_price)
--         FROM order_items oi
--         JOIN products p
--           ON oi.order_items_product_id = p.product_id
--        WHERE oi.order_items_order_id = NEW.order_id
--     )
--   WHERE order_id = NEW.order_id;
--
--  RETURN NEW;
--END;
--$$;
--
--CREATE TRIGGER trg_recalculate_order_sum
--  AFTER INSERT OR UPDATE ON orders
--  FOR EACH ROW
--  EXECUTE FUNCTION recalculate_order_sum();



CREATE OR REPLACE FUNCTION recalc_order_sum_before()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
BEGIN
  NEW.order_sum := (
    SELECT SUM(oi.quantity * p.unit_price)
      FROM order_items oi
      JOIN products p ON oi.order_items_product_id = p.product_id
     WHERE oi.order_items_order_id = NEW.order_id
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_recalc_order_sum ON orders;
CREATE TRIGGER trg_recalc_order_sum
  BEFORE INSERT OR UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION recalc_order_sum_before();
