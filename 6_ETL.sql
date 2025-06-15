BEGIN;

INSERT INTO dim_time (full_date, day, month, quarter, year)
SELECT DISTINCT d,
       EXTRACT(DAY    FROM d),
       EXTRACT(MONTH  FROM d),
       EXTRACT(QUARTER FROM d),
       EXTRACT(YEAR   FROM d)
  FROM (
    SELECT start_date AS d FROM staging.orders
    UNION
    SELECT end_date   AS d FROM staging.orders
  ) x
 WHERE d IS NOT NULL
   AND NOT EXISTS (
     SELECT 1 FROM dim_time t WHERE t.full_date = x.d
   );

INSERT INTO dim_country (country_name)
SELECT DISTINCT s.country_name
  FROM staging.countries s
 WHERE NOT EXISTS (
     SELECT 1 FROM dim_country d 
      WHERE d.country_name = s.country_name
   );

INSERT INTO dim_city (city_name, country_sk)
SELECT s.city_name,
       dc.country_sk
  FROM staging.cities s
  JOIN dim_country dc
    ON dc.country_name = (
         SELECT country_name
           FROM staging.countries c2
          WHERE c2.country_id = s.city_country_id
       )
 ON CONFLICT (city_name, country_sk) DO NOTHING;

INSERT INTO dim_address (address_name, postal_code, city_sk)
SELECT a.address_name,
       a.postal_code,
       dc.city_sk
  FROM staging.addresses a
  JOIN dim_city dc
    ON dc.city_name = (
         SELECT city_name 
           FROM staging.cities c3 
          WHERE c3.city_id = a.address_city_id
       )
   AND dc.country_sk = (
         SELECT country_sk
           FROM dim_country 
          WHERE country_name = (
            SELECT country_name 
              FROM staging.countries
             WHERE country_id = (
               SELECT city_country_id 
                 FROM staging.cities
                WHERE city_id = a.address_city_id
             )
          )
       )
 ON CONFLICT (address_name, postal_code, city_sk) DO NOTHING;

INSERT INTO dim_category (category_name)
SELECT DISTINCT s.category_name
  FROM staging.categories s
 WHERE NOT EXISTS (
     SELECT 1 FROM dim_category d 
      WHERE d.category_name = s.category_name
   );

INSERT INTO dim_product (
   product_id,
   product_name,
   unit_price,
   manufacturer,
   brand
)
SELECT DISTINCT
   p.product_id::TEXT,
   p.product_name,
   p.unit_price,
   sm.manufacturer_name,
   sb.brand_name
  FROM staging.products p
  JOIN staging.manufacturers sm 
    ON sm.manufacturer_id = p.product_manufacturer_id
  JOIN staging.brands sb 
    ON sb.brand_id = p.product_brand_id
 WHERE NOT EXISTS (
     SELECT 1 
       FROM dim_product d 
      WHERE d.product_id = p.product_id::TEXT
   );

INSERT INTO bridge_product_category (product_sk, category_sk)
SELECT
  dp.product_sk,
  dc.category_sk
  FROM staging.products p
  JOIN dim_product      dp 
    ON dp.product_id = p.product_id::TEXT
  JOIN staging.categories sc 
    ON sc.category_id = p.product_category_id
  JOIN dim_category    dc 
    ON dc.category_name = sc.category_name
 ON CONFLICT (product_sk, category_sk) DO NOTHING;

UPDATE dim_customer d
   SET effective_to = CURRENT_DATE - 1,
       is_current   = FALSE
  FROM staging.customers s
 WHERE d.is_current
   AND d.customer_id::TEXT = s.customer_id::TEXT
   AND (
        d.first_name    IS DISTINCT FROM s.first_name
     OR d.last_name     IS DISTINCT FROM s.last_name
     OR d.gender        IS DISTINCT FROM s.gender
     OR d.date_of_birth IS DISTINCT FROM s.date_of_birth
     OR d.email         IS DISTINCT FROM s.email
     OR d.phone_number  IS DISTINCT FROM s.phone_number
   );

INSERT INTO dim_customer (
  customer_id,
  first_name,
  last_name,
  gender,
  date_of_birth,
  email,
  phone_number,
  effective_from,
  is_current
)
SELECT
  s.customer_id::TEXT,
  s.first_name,
  s.last_name,
  s.gender,
  s.date_of_birth,
  s.email,
  s.phone_number,
  s.member_since AS effective_from,
  TRUE         AS is_current
  FROM staging.customers s
  LEFT JOIN dim_customer d
    ON d.customer_id = s.customer_id::TEXT
   AND d.is_current
 WHERE d.customer_sk IS NULL
    OR d.first_name    IS DISTINCT FROM s.first_name
    OR d.last_name     IS DISTINCT FROM s.last_name
    OR d.gender        IS DISTINCT FROM s.gender
    OR d.date_of_birth IS DISTINCT FROM s.date_of_birth
    OR d.email         IS DISTINCT FROM s.email
    OR d.phone_number  IS DISTINCT FROM s.phone_number;

INSERT INTO fact_orders (
  customer_sk,
  address_sk,
  time_sk,
  total_orders,
  total_revenue
)
SELECT
  dc.customer_sk,
  da.address_sk,
  dt.time_sk,
  COUNT(*)         AS total_orders,
  SUM(o.order_sum) AS total_revenue
  FROM staging.orders o
  JOIN dim_customer dc 
    ON dc.customer_id = o.order_customer_id::TEXT
   AND dc.is_current
  JOIN staging.addresses sa 
    ON sa.address_id = o.delivery_address_id
  JOIN dim_address da 
    ON da.address_name = sa.address_name
   AND da.postal_code = sa.postal_code
  JOIN dim_time dt 
    ON dt.full_date = o.start_date
  LEFT JOIN fact_orders f 
    ON f.customer_sk = dc.customer_sk
   AND f.address_sk  = da.address_sk
   AND f.time_sk     = dt.time_sk
 WHERE f.order_sk IS NULL
 GROUP BY dc.customer_sk, da.address_sk, dt.time_sk;

INSERT INTO fact_order_items (
  order_sk,
  product_sk,
  quantity_sold,
  item_price,
  item_revenue
)
SELECT
  fo.order_sk,
  dp.product_sk,
  oi.quantity      AS quantity_sold,
  dp.unit_price    AS item_price,
  oi.quantity * dp.unit_price AS item_revenue
  FROM staging.order_items oi
  JOIN staging.orders o 
    ON o.order_id = oi.order_items_order_id
  JOIN dim_customer dc 
    ON dc.customer_id = o.order_customer_id::TEXT
   AND dc.is_current
  JOIN dim_time dt 
    ON dt.full_date = o.start_date
  JOIN dim_product dp 
    ON dp.product_id = oi.order_items_product_id::TEXT
  JOIN fact_orders fo 
    ON fo.customer_sk = dc.customer_sk
   AND fo.time_sk     = dt.time_sk
  LEFT JOIN fact_order_items x 
    ON x.order_sk      = fo.order_sk
   AND x.product_sk    = dp.product_sk
   AND x.quantity_sold = oi.quantity
 WHERE x.item_sk IS NULL;

INSERT INTO fact_daily_sales (
  date_sk,
  total_orders,
  total_revenue
)
SELECT
  dt.time_sk,
  SUM(f.total_orders),
  SUM(f.total_revenue)
  FROM fact_orders f
  JOIN dim_time dt 
    ON dt.time_sk = f.time_sk
 GROUP BY dt.time_sk
ON CONFLICT (date_sk) DO UPDATE
  SET total_orders  = EXCLUDED.total_orders,
      total_revenue = EXCLUDED.total_revenue;

COMMIT;
