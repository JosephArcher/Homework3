-- Joe Archer
-- 10/07/13
-- Queries HW # 3

-- 1. Get the cities of agents booking an order for customer c002. Use a subquery. (Yes, this is the same question as on homework # 2)

SELECT distinct city  -- The Outer Query will take the aids and find the city where they live
FROM agents
WHERE aid IN (SELECT aid FROM orders WHERE cid = 'c002') -- Inner Query will return the aid of agents who are booking an order for c002

-- 2. Get the cities of agents booking an order for customer c002. This time use joins; no subqueries

SELECT distinct Agents.City -- Distinct becuase you dont want more then one of the same city being returned
FROM Agents
JOIN Orders
ON orders.aid = agents.aid
WHERE orders.cid = 'c002'  -- Checks the orders table for any cid equal to c002

-- 3. Get the pids of products ordered through any agent who makes at least one order for a customer in Kyoto. Use subqueries. (Yes, this is also the same question as on homework #2)

SELECT distinct pid
FROM orders     
WHERE aid IN (
SELECT distinct aid  -- This Query Returns the aids from the orders table that have the same cid's returned from the inner query
FROM orders 
WHERE cid IN ( SELECT cid FROM customers where city = 'Kyoto' ) -- The Inner most Query returns the cid's for customers in Kyoto
) 

-- 4. Get the pids of products ordered through any agent who makes at least one order for a customer in Kyoto. Use joins this time; no subqueries

select distinct b.pid
from orders a full outer join orders b on a.aid = b.aid, customers c -- joins orders to orders to customers
where c.cid = a.cid and c.city = 'Kyoto' -- limits the results to only customeers in Kyoto
order by b.pid  


-- 5. Get the name of customers who have never placed an order. Use a subquery

SELECT name
FROM customers
where cid NOT IN ( -- used not in so that it returns customers who did not order
	SELECT distinct cid -- The inner query returns cid who placed an order
	FROM orders  )
	
-- 6. Get the name of customers who have never placed an order. Use an outer join

Select customers.name
from customers 
full outer join orders -- Had to use a full join becuase c005 is not listed in the orders.cid column
on customers.cid = orders.cid
WHERE orders.cid is null

-- 7. Get the names of customers who placed at least one order through an agent in their city, along with those agent(s) names

SELECT distinct customers.name, agents.name
from customers , agents , orders
where customers.city = agents.city -- links customers and agents
and customers.cid = orders.cid  -- links customers and orders
and orders.aid = agents.aid -- links orders and agents

-- 8. Get the names of customers and agents in the same city, along with the name of the city, regardless of whether or not the customer has ever placed an order with that agent

Select customers.name , agents.name , customers.city
from customers, agents
where customers.city = agents.city -- links customers and agents together

-- 9. Get the name and city of customers who live in the city where the least number of products are made

SELECT customers.name , customers.city  
from customers
where city IN (
SELECT products.city -- this query will return any cities that have the min number of products made there
from products
group by city      
Having Count(city) IN ( (SELECT MIN (Num ) from (SELECT Count(city) as Num from products group by products.city)as a ) ) -- this inner most query will return the min number
)    

-- 10. Get the name and city of customers who live in a city where the most number of prodcuts are made

SELECT customers.name , customers.city 
from customers
where city IN (
SELECT products.city
from products
group by products.city
Having Count(city) IN ( (SELECT MAX (Num ) from (SELECT Count(city) as Num from products group by products.city)as a ) )
LIMIT 1 -- limits what the query returns so only 1 city is returned
)


-- 11. Get the name and city of customers who live in ANY city where the most number of products are made

SELECT customers.name , customers.city 
from customers
where city IN (
SELECT products.city -- this query finds the names of the cities that have the max number of orders
from products
group by city
Having Count(city) IN ( (SELECT MAX (Num ) from (SELECT Count(city) as Num from products group by products.city)as a ) )
)

-- 12. 	List the products whose priceUSD is above the average priceUSD

SELECT Name
FROM Products
where priceUSD > (SELECT AVG(PriceUSD )as avg from products) -- This will calculate the average to then compare to the price

-- 13. 	Show the customer name, pid ordered, and the dollars for all customer orders, sorted by dollars from high to low

SELECT  customers.name , orders.dollars , orders.pid 
FROM orders
JOIN customers
ON Customers.cid = orders.cid -- links customers and orders table
ORDER BY dollars desc -- orders the dollars column from high to low

-- 14. 	Show all customer names (in order) and their total ordered, and nothing more. Use coalesce to avoid showing nulls

Select a.name ,COALESCE( Sum (dollars ), 0) as TOTAL  -- coalesce is used so that a 0 is used instead of a null
from (Select customers.name , customers.cid ,orders.dollars
from orders
full outer join customers  -- had to use a full outer join because weyland is not in the orders table
on orders.cid = customers.cid) as a
group by a.name,a.cid -- grouped by cid to avoid customers with same name being added together 
order by a.name 

-- 15. 	Show the names of all customers who bought products from agents based in New York along with the names of the products they ordered, and the names of the agents who sold it to them


SELECT customers.name , agents.name , products.name
from customers , agents , products , orders
where customers.cid = orders.cid -- links orders and customers
and agents.aid = orders.aid -- links agents and orders
and products.pid = orders.pid -- links products and orders
and agents.city = 'New York' -- limits the output to agents only in New York 


-- 16.  Write a query to check the accuracy of the dollars column in the Orders table. This means calculating Orders.dollars from other data in other tables and then comparing those values to the values in Orders.dollars

Select orders.dollars as ORIGINAL , a.RECALCULATED
from orders
FULL OUTER JOIN (SELECT orders.ordno , (products.priceUSD * orders.qty ) - ((products.priceUSD * orders.qty )* (customers.discount / 100))   as RECALCULATED -- Recalculates the dollars column
from customers , agents , products , orders
where orders.cid = customers.cid -- links orders and customers
and orders.aid = agents.aid -- links orders and agents
and orders.pid = products.pid --links orders and products
group by orders.ordno , (products.priceUSD * orders.qty ) - ((products.priceUSD * orders.qty )* (customers.discount / 100))
order by ordno) as a
ON orders.ordno = a.ordno

-- 17. 	Create an error in the dollars column of the Orders table so that you can verify your accuracy checking query

Select  orders.ordno , orders.dollars , a.RECALCULATED
from orders
FULL OUTER JOIN (SELECT orders.ordno , (products.priceUSD * orders.qty ) - ((products.priceUSD * orders.qty )* (customers.discount / 100))   as RECALCULATED -- Recalculates the dollars column
from customers , agents , products , orders
where orders.cid = customers.cid
and orders.aid = agents.aid
and orders.pid = products.pid
group by orders.ordno , (products.priceUSD * orders.qty ) - ((products.priceUSD * orders.qty )* (customers.discount / 100))
order by ordno) as a
ON orders.ordno = a.ordno
group by orders.ordno , a.ordno , a.RECALCULATED
having orders.dollars != a.RECALCULATED -- compares the columns and makes it so the query only returns errrors
order by orders.ordno


