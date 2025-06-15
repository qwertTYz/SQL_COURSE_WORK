-- how many customers joined last year
SELECT
  COUNT(*) AS customers_joined_last_year
FROM Customers
WHERE Member_Since >= CURRENT_DATE - INTERVAL '1 year';

-- 5 customers with most orders
SELECT
  c.First_Name || ' ' || c.Last_Name AS Customer_Name,
  COUNT(o.Order_ID) AS Total_Orders
FROM Orders o
JOIN Customers c ON o.Order_Customer_ID = c.Customer_ID
GROUP BY Customer_Name
ORDER BY Total_Orders DESC
LIMIT 5;



-- 5 most popular products of all time

SELECT
  p.Product_Name,
  SUM(oi.Quantity) AS total_sold_all_time
FROM Order_Items oi
JOIN Products p
  ON oi.Order_Items_Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY total_sold_all_time DESC
LIMIT 5;
