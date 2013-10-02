-- Joe Archer
-- Queries HW # 3

-- 1. Get the cities of agents booking an order for customer c002. Use a subquery. (Yes, this is the same question as on homework # 2)

SELECT distinct
city
FROM 
agents
WHERE aid IN (
SELECT 
aid
FROM
orders
WHERE 
cid = 'c002'
)
-- 2. Get the cities of agents booking an order for customer c002. This time use joins; no subqueries

SELECT distinct Agents.City 
FROM Agents
JOIN Orders
ON orders.aid = agents.aid
WHERE orders.cid = 'c002'

-- 3. Get the pids of products ordered through any agent who makes at least one order for a customer in Kyoto. Use subqueries. (Yes, this is also the same question as on homework #2)
SELECT distinct pid
FROM orders
WHERE aid IN (
SELECT distinct aid
FROM orders
WHERE cid = (
SELECT cid
FROM customers
where city = 'Kyoto' 
)
)

-- 4. Get the pids of products ordered through any agent who makes at least one order for a customer in Kyoto. Use joins this time; no subqueries



-- 5. Get the name of customers who have never placed an order. Use a subquery
SELECT name
FROM customers
where cid NOT IN (
	SELECT distinct cid
	FROM orders
	
	)
	
-- 6. Get the name of customers who have never placed an order. Use an outer join

Select customers.name
from customers 
full outer join orders
on customers.cid = orders.cid
WHERE orders.cid is null

-- 7. Get the names of customers who placed at least one order through an agent in their city, along with those agent(s) names

SELECT  distinct customers.name, agents.name
from customers , agents , orders
where customers.city = agents.city
and customers.cid = orders.cid
and orders.aid = agents.aid

-- 8. Get the names of customers and agents in the same city, along with the name of the city, regardless of whether or not the customer has ever placed an order with that agent

Select customers.name , agents.name , customers.city
from customers, agents
where customers.city = agents.city

-- 9. Get the name and city of customers who live in the city where the least number of products are made

SELECT customers.name , customers.city 
from customers
where city IN (
SELECT products.city
from products
group by city
Having Count(city) IN ( (SELECT MIN (Num ) from (SELECT Count(city) as Num from products group by products.city)as a ) )
)

-- 10. Get the name and city of customers who live in a city where the most number of prodcuts are made

SELECT customers.name , customers.city 
from customers
where city IN (
SELECT products.city
from products
group by products.city
Having Count(city) IN ( (SELECT MAX (Num ) from (SELECT Count(city) as Num from products group by products.city)as a ) )
LIMIT 1
)


-- 11. Get the name and city of customers who live in ANY city where the most number of products are made

SELECT customers.name , customers.city 
from customers
where city IN (
SELECT products.city
from products
group by city
Having Count(city) IN ( (SELECT MAX (Num ) from (SELECT Count(city) as Num from products group by products.city)as a ) )
)

-- 12. 	List the products whose priceUSD is above the average priceUSD

SELECT Name
FROM Products
where priceUSD > (SELECT AVG(PriceUSD )as avg from products)

-- 13. 	Show the customer name, pid ordered, and the dollars for all customer orders, sorted by dollars from high to low

SELECT  customers.name , orders.dollars , orders.pid 
FROM orders
JOIN customers
ON Customers.cid = orders.cid
ORDER BY dollars desc 

-- 14. 	Show all customer names (in order) and their total ordered, and nothing more. Use coalesce to avoid showing nulls

Select a.name ,COALESCE( Sum (dollars ), 0) as TOTAL 
from (Select customers.name , customers.cid ,orders.dollars
from orders
full outer join customers
on orders.cid = customers.cid) as a
group by a.name,a.cid
order by a.name

-- 15. 	Show the names of all customers who bought products from agents based in New York along with the names of the products they ordered, and the names of the agents who sold it to them

SELECT orders.pid , orders.cid , orders.aid 
From orders
where cid IN ( SELECT distinct cid from orders where aid IN ( SELECT aid FROM agents WHERE city = 'New York' ) )   

-- 16.  Write a query to check the accuracy of the dollars column in the Orders table. This means calculating Orders.dollars from other data in other tables and then comparing those values to the values in Orders.dollars

Select orders.dollars as ORIGINAL , a.RECALCULATED
from orders
FULL OUTER JOIN (SELECT orders.ordno , (products.priceUSD * orders.qty ) - ((products.priceUSD * orders.qty )* (customers.discount / 100))   as RECALCULATED
from customers , agents , products , orders
where orders.cid = customers.cid
and orders.aid = agents.aid
and orders.pid = products.pid
group by orders.ordno , (products.priceUSD * orders.qty ) - ((products.priceUSD * orders.qty )* (customers.discount / 100))
order by ordno) as a
ON orders.ordno = a.ordno

-- 17. 	Create an error in the dollars column of the Orders table so that you can verify your accuracy checking query



Select  orders.ordno , orders.dollars , a.RECALCULATED
from orders
FULL OUTER JOIN (SELECT orders.ordno , (products.priceUSD * orders.qty ) - ((products.priceUSD * orders.qty )* (customers.discount / 100))   as RECALCULATED
from customers , agents , products , orders
where orders.cid = customers.cid
and orders.aid = agents.aid
and orders.pid = products.pid
group by orders.ordno , (products.priceUSD * orders.qty ) - ((products.priceUSD * orders.qty )* (customers.discount / 100))
order by ordno) as a
ON orders.ordno = a.ordno
group by orders.ordno , a.ordno , a.RECALCULATED
having orders.dollars != a.RECALCULATED
order by orders.ordno


