CREATE DATABASE ECommerce_Data_Analysis;
USE ECommerce_Data_Analysis;

-- Questions

-- Question1
-- find the profit margin for different productslines?

select productLine, concat(round(avg((msrp-buyPrice)/buyPrice)*100,2),"%") as profit
from products
group by 1
order by 2 desc;
-- in this q   i have assumed buyprice is the price at which the shopkeeper buy products, and sell products at MSRP
-- profit formula- (sp-cp/cp)

-- Question2
-- Calculate avg time for orders placed and orders shipped

select round(avg(datediff(shippeddate,orderdate)),2)
from orders;

-- Question 3
-- Find the creditlimit, amount paid and count no of orders places for each customer;

select   c.customernumber, customername, creditlimit, sum(amount) as total_amt, count(ordernumber) as no_of_orders_placed
from customers c
left join payments p
on c.customernumber=p.customernumber
left join orders o
on c.customernumber=o.customernumber
where creditlimit>0
group by 1,2
having sum(amount)>0
order by no_of_orders_placed desc, total_amt desc, creditlimit desc;

-- Question 4
-- Find the customers who have exhausted their creditlimit  

select   c.customernumber, customername, creditlimit, sum(amount) as total_amt
from customers c
left join payments p
on c.customernumber=p.customernumber
group by 1,2
having sum(amount)>creditlimit
order by total_amt desc, creditlimit desc;

-- Questions5
-- Calculate the % for total_amt exceeding creditlimit

select   c.customernumber, customername, creditlimit, sum(amount) as total_amt,
concat(round((sum(amount)-creditlimit)*100/creditlimit,2),"%") as exceed_creditlimit_percentage
from customers c
left join payments p
on c.customernumber=p.customernumber
group by 1,2
having sum(amount)>creditlimit
order by  exceed_creditlimit_percentage desc,
total_amt desc, creditlimit desc;

-- Question 6
-- Find the top 2 products sold in each productline
with cte as(
 select  productname, productline, sum(quantityOrdered) as total_quantity, 
 dense_rank() over(partition by  productline order by sum(quantityOrdered) desc) as rnk
 from orderdetails o
 left join products p
 on p.productcode=o.productcode
 group by 1,2)
 select productname, productline, total_quantity, rnk
 from cte
 where rnk<=2
;

select productvendor, productline,sum(quantityinstock) from products
group by 1,2
order by 3 desc;

-- Question 7
-- Find the top 2  cities from each country where customers are ordering the most and see their creditlimit

with cte as(
select city, country,sum(amount) as total_amount,sum(creditlimit) as total_limit, 
sum(quantityordered) as total_orders, 
count(c.customernumber) as total_customers ,count(o.ordernumber)as order_count,
dense_rank() over (partition by country order by sum(amount) desc,sum(creditlimit) desc, 
sum(quantityordered) desc) as rnk
from customers c
left join payments p
on c.customernumber=p.customernumber
left join orders o
on c.customernumber=o.customernumber
left join orderdetails od
on o.ordernumber=od.ordernumber
group by 1
having count(o.ordernumber)>0
)
select city, country,total_amount,total_limit, total_orders, total_customers, order_count,rnk
from cte
where rnk<=2;

-- question 8
-- Find the avg order value of order placed

select avg(quantityordered*priceEach) from  orderdetails;

-- Question 9
-- Find vendors and how many quantity they have in stock

select productvendor,sum(quantityinStock)
from products
group by 1
order by 2 desc;

-- Question 10
-- Find Customers who have made payment the same day when they have ordered products
  
select count(*) from customers c
left join payments p 
on c.customernumber=p.customernumber
left join orders o
on c.customernumber=o.customernumber
where paymentdate=orderdate ;

-- Question 11
-- Count the status of all the orders placed

 select  `status`, count(ordernumber)
 from orders
 group by 1
 order by 2 desc;
 
 -- Question 12
 -- Count the productname ordered by each office
 
 select o.officecode, pc.productcode, productname, count(*) as total_orders
 from offices o
 left join employees e
 on o.officecode=e.officecode
 left join customers c
 on employeenumber=salesrepemployeenumber
 left join orders ord
 on c.customernumber=ord.customernumber
 left join orderdetails od
 on ord.ordernumber=od.ordernumber
 left join products pc
 on od.productcode=pc.productcode
 where pc.productcode is not null
 group by 1,2,3
 order by 1,2,3
 ;
 
 -- Question 13
 --  Total order amount of each office
 with cte as
 (select o.officecode, sum(amount) as total_amt
 from offices o
 left join employees e
 on o.officecode=e.officecode
 left join customers c
 on employeenumber=salesrepemployeenumber
 left join payments p
 on p.customernumber=c.customernumber
 group by 1
 order by 1)
 select officecode, concat(round((total_amt/1000),2) ,' k') as total_order_amount
 from cte;
