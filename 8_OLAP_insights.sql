-- show customers joined per year
SELECT
  EXTRACT(YEAR FROM dc.effective_from) AS join_year,
  COUNT(*) AS num_customers
FROM dim_customer dc
GROUP BY join_year
ORDER BY join_year DESC;


-- how many customers joined since 2004-01-01?
SELECT
  COUNT(*) AS customers_joined_since_2004
FROM dim_customer
WHERE  effective_from >= DATE '2004-01-01';

-- show total revenue by country and quarter
SELECT
  dc.country_name,
  dt.year,
  dt.quarter,
  SUM(f.total_revenue) AS revenue
FROM fact_orders f
JOIN dim_time dt
  ON f.time_sk = dt.time_sk
JOIN dim_address da
  ON f.address_sk = da.address_sk
JOIN dim_city ci
  ON da.city_sk = ci.city_sk
JOIN dim_country dc
  ON ci.country_sk = dc.country_sk
GROUP BY dc.country_name, dt.year, dt.quarter
ORDER BY dc.country_name, dt.year, dt.quarter;
