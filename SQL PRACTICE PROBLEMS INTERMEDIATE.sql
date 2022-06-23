--  -----------------------------------SQL Practice Problems - Intermediate-------------------------

/*20. Categories, and the total products in each category
For this problem, we’d like to see the total number of products in each
category. Sort the results by the total number of products, in descending
order.*/
use northwind_db;
select
c.category_name,
count(p.product_id) as Total_Products
from products as p
join categories as c on p.category_id=c.category_id
group by c.category_name
order by count(p.product_id)desc;

/*21. Total customers per country/city
In the Customers table, show the total number of customers per Country
and City.*/
select 
country, city, 
COUNT(customer_id) AS TotalCustomers
from customers
group by country, city
ORDER BY  COUNT(customer_id) DESC;

/* 22) 22. Products that need reordering
What products do we have in our inventory that should be reordered?
For now, just use the fields UnitsInStock and ReorderLevel, where
UnitsInStock is less than the ReorderLevel, ignoring the fields
UnitsOnOrder and Discontinued.
Order the results by ProductID. */
select product_id, product_name, units_in_stock, reorder_level
from products
where  units_in_stock < reorder_level
order by product_id;

/*23. Products that need reordering, continued
Now we need to incorporate these fields—UnitsInStock, UnitsOnOrder,
ReorderLevel, Discontinued—into our calculation. We’ll define
“products that need reordering” with the following:
UnitsInStock plus UnitsOnOrder are less than or equal to
ReorderLevel
The Discontinued flag is false (0).*/
select product_id, product_name, units_in_stock, units_on_order,
       reorder_level, discontinued
from products
where  units_in_stock + units_on_order < reorder_level
and discontinued = 0
order by product_id;

/*24. Customer list by region
A salesperson for Northwind is going on a business trip to visit
customers, and would like to see a list of all customers, sorted by
region, alphabetically.
However, he wants the customers with no region (null in the Region
field) to be at the end, instead of at the top, where you’d normally find
the null values. Within the same region, companies should be sorted by
CustomerID.*/

Select T.customer_id, T.company_name, T.region
from
    (Select customer_id, company_name, region,
            Case when region is null 
            then 1 
            else 0 
            End As SortField
    from customers) AS T
order by T.SortField, T.region, T.customer_id;

/*25. High freight charges
Some of the countries we ship to have very high freight charges. We'd
like to investigate some more shipping options for our customers, to be
able to offer them lower freight charges. Return the three ship countries
with the highest average freight overall, in descending order by average
freight.*/
select* from orders;

select ship_country,
AVG(freight) as AverageFreight
from orders
group by ship_country
order by AVG(freight) desc
limit 3;

/*26. High freight charges - 2015
We're continuing on the question above on high freight charges. Now,
instead of using all the orders we have, we only want to see orders from
the year 2015*/
select * from orders;
select ship_country,
avg(freight)as Average_Freight
from orders
where order_date>='2015-01-01' and order_date<='2016-01-01'
group by ship_country
order by Average_Freight desc
limit 3;

/*27) High freight charges with between
Another (incorrect) answer to the problem above is this:
/* Select Top 3
ShipCountry
,AverageFreight = avg(freight)
From Orders
Where
OrderDate between '1/1/2015' and '12/31/2015'
Group By ShipCountry
Order By AverageFreight desc;
Notice when you run this, it gives Sweden as the ShipCountry with the
third highest freight charges. However, this is wrong - it should be
France.
What is the OrderID of the order that the (incorrect) answer above is
missing? */
select 
ship_country,
avg(freight) as Average_Freight 
from orders
where
order_date between '1/1/2015' and '12/31/2015'
group by ship_country
order by Average_Freight desc;

/* 28)High freight charges - last year
 We're continuing to work on high freight charges. We now want to get
-- the three ship countries with the highest average freight charges. But
-- instead of filtering for a particular year, we want to use the last 12
--- months of order data, using as the end date the last OrderDate in Orders.*/
select * from orders;
select 
ship_country,
-- count(ship_country)as Total,
avg(freight) as Average_Freight
from orders
where order_date >= date ((select max(order_date)from orders)-interval 12 month)
group by ship_country
order by Average_Freight desc
limit 3;

/* 29. Inventory list
We're doing inventory, and need to show information like the below, for
all orders. Sort by OrderID and Product ID.*/

select  O.employee_id, E.last_name, O.order_id, P.product_name, OD.quantity
from employees AS E, orders AS O, products AS P, order_details as OD
where
O.employee_id = E.employee_id
and
OD.order_id = O.order_id
and
OD.product_id = P.product_id;

/*30. Customers with no orders
There are some customers who have never actually placed an order.
Show these customers*/
select 
customer_id 
from customers
where
customer_id not in 
(select distinct(customer_id)from orders);

/*--31. Customers with no orders for EmployeeID 4
One employee (Margaret Peacock, EmployeeID 4) has placed the most
orders. However, there are some customers who've never placed an order
with her. Show only those customers who have never placed an order
with her.*/

select 
customer_id 
from customers
where
customer_id not in 
(select distinct(customer_id)from orders where employee_id=4);