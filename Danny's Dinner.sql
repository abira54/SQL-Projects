CREATE DATABASE dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
GO

SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

--What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) AS spent_amt FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY spent_amt DESC;

--How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) as visited_days FROM sales
GROUP BY customer_id
ORDER BY visited_days DESC;

--What was the first item from the menu purchased by each customer?

SELECT DISTINCT s.customer_id ,FIRST_VALUE(m.product_name) OVER(PARTITION BY s.customer_id ORDER BY order_date ASC) as first_item FROM sales s
JOIN menu m
ON s.product_id = m.product_id

SELECT DISTINCT s.customer_id,m.product_name FROM sales s
JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date IN (SELECT min(order_date) FROM sales GROUP BY customer_id ) 

--What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP(1) m.product_name, COUNT(s.product_id) unit_sold FROM sales s
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY unit_sold DESC;

--Which item was the most popular for each customer?

WITH popular_item AS(
	SELECT s.customer_id, m.product_name, COUNT(s.product_id) as unit_bought FROM sales s
	JOIN menu m 
	ON s.product_id = m.product_id
	GROUP BY m.product_name, s.customer_id
	--ORDER BY s.customer_id, unit_bought DESC
)
SELECT * FROM popular_item
WHERE unit_bought IN (SELECT MAX(unit_bought) FROM popular_item)

---Which item was purchased first by the customer after they became a member?

SELECT DISTINCT s.customer_id ,FIRST_VALUE(m.product_name) OVER(PARTITION BY s.customer_id ORDER BY order_date ASC) as first_item FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON mem.customer_id = s.customer_id AND mem.join_date <= s.order_date

--Which item was purchased just before the customer became a member?

SELECT DISTINCT s.customer_id ,FIRST_VALUE(m.product_name) OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) as first_item FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON mem.customer_id = s.customer_id AND mem.join_date > s.order_date

SELECT DISTINCT s.customer_id,m.product_name FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON mem.customer_id = s.customer_id AND mem.join_date > s.order_date
WHERE s.order_date IN (SELECT min(order_date) FROM sales GROUP BY customer_id ) 
ORDER BY s.customer_id;


--What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.product_id) as item_bought ,SUM(m.price) AS spent_amt FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON mem.customer_id = s.customer_id AND mem.join_date > s.order_date
GROUP BY s.customer_id
ORDER BY s.customer_id; 

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, SUM(CASE WHEN m.product_name='sushi' THEN m.price*20 ELSE m.price*10 END) AS points FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY points DESC;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?

SELECT s.customer_id, SUM(CASE WHEN s.order_date BETWEEN mem.join_date AND DATEADD(DAY, 7, mem.join_date) THEN
						m.price*20 
						ELSE
						CASE WHEN m.product_name='sushi' THEN m.price*20 ELSE m.price*10 END
						END) AS points FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON mem.customer_id = s.customer_id AND mem.join_date <= s.order_date
WHERE s.order_date < '2021-02-01'
GROUP BY s.customer_id
ORDER BY s.customer_id; 
