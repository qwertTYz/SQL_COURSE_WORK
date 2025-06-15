-- DIMENSIONS
CREATE TABLE dim_country (
  country_sk   SERIAL PRIMARY KEY,
  country_name TEXT       UNIQUE
);

CREATE TABLE dim_city (
  city_sk     SERIAL PRIMARY KEY,
  city_name   TEXT,
  country_sk  INT        NOT NULL
    REFERENCES dim_country(country_sk),
  UNIQUE(city_name, country_sk)
);

CREATE TABLE dim_time (
  time_sk    SERIAL PRIMARY KEY,
  full_date  DATE       UNIQUE,
  day        INT,
  month      INT,
  quarter    INT,
  year       INT
);

CREATE TABLE dim_address (
  address_sk   SERIAL PRIMARY KEY,
  address_name TEXT       NOT NULL,
  postal_code  TEXT,
  city_sk      INT        NOT NULL
    REFERENCES dim_city(city_sk),
  UNIQUE(address_name, postal_code, city_sk)
);

CREATE TABLE dim_category (
  category_sk   SERIAL PRIMARY KEY,
  category_name TEXT       UNIQUE
);

CREATE TABLE dim_product (
  product_sk    SERIAL PRIMARY KEY,
  product_id    TEXT       UNIQUE,
  product_name  TEXT,
  -- we drop category_name here in favor of the bridge
  unit_price    NUMERIC(10,2),
  manufacturer  TEXT,
  brand         TEXT
);

CREATE TABLE dim_customer (
  customer_sk     SERIAL PRIMARY KEY,
  customer_id     TEXT,                    -- business key
  first_name      TEXT,
  last_name       TEXT,
  gender          TEXT,
  date_of_birth   DATE,
  email           TEXT,
  phone_number    TEXT,
  effective_from  DATE      NOT NULL,
  effective_to    DATE,
  is_current      BOOLEAN   NOT NULL DEFAULT TRUE,
  UNIQUE(customer_id, effective_from)
);

-- BRIDGE: many‐to‐many product ↔ category
CREATE TABLE bridge_product_category (
  product_sk  INT NOT NULL
    REFERENCES dim_product(product_sk),
  category_sk INT NOT NULL
    REFERENCES dim_category(category_sk),
  PRIMARY KEY (product_sk, category_sk)
);

-- FACTS
CREATE TABLE fact_orders (
  order_sk       SERIAL PRIMARY KEY,
  customer_sk    INT   REFERENCES dim_customer(customer_sk),
  address_sk     INT   REFERENCES dim_address(address_sk),
  time_sk        INT   REFERENCES dim_time(time_sk),
  total_orders   BIGINT,
  total_revenue  NUMERIC(10,2)
);

CREATE TABLE fact_order_items (
  item_sk         SERIAL PRIMARY KEY,
  order_sk        INT   REFERENCES fact_orders(order_sk),
  product_sk      INT   REFERENCES dim_product(product_sk),
  quantity_sold   INT,
  item_price      NUMERIC(10,2),
  item_revenue    NUMERIC(10,2)
);

CREATE TABLE fact_daily_sales (
  day_sk         SERIAL PRIMARY KEY,
  date_sk        INT   REFERENCES dim_time(time_sk) UNIQUE,
  total_orders   BIGINT,
  total_revenue  NUMERIC(10,2)
);
