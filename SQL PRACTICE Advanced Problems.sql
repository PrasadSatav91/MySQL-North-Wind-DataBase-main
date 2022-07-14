-- ADVANCED PROBLEMS

-- 32. High-value customers
/*
   We want to send all of our high-value customers a special VIP gift.
   We're defining high-value customers as those who've made at least 1
   order with a total value (not including the discount) equal to $10,000 or
   more. We only want to consider orders made in the year 2016.
*/

select 
      c.customer_id,
      c.company_name,
      o.order_id,
      sum(od.unit_price*od.quantity) as Total
from customers  as c
     left join orders as o
         on c.customer_id = o.customer_id
     left join order_details as od
         on  o.order_id = od.order_id
where o.order_date >= '2016-01-01' and  o.order_date <= '2016-01-31'
group by customer_id , c.company_name, order_id
having total > 10000;

-- 33. High-value customers - total orders
/*
   The manager has changed his mind. Instead of requiring that customers
   have at least one individual orders totaling $10,000 or more, he wants to
   define high-value customers as those who have orders totaling $15,000
   or more in 2016. How would you change the answer to the problem
   above?
*/

select 
      c.customer_id,
      c.company_name,
      o.order_id,
      sum(od.unit_price*od.quantity) as Total
from customers  as c
   left join orders as o
       on c.customer_id = o.customer_id
   left join order_details as od
       on  o.order_id = od.order_id
where o.order_date >= '2016-01-01' and  o.order_date <= '2016-01-31'
group by customer_id , c.company_name, order_id
having total > 15000;

-- 34. High-value customers - with discount
/*
   Change the above query to use the discount when calculating high-value
   customers. Order by the total amount which includes the discount.
*/

select 
      c.customer_id,
      c.company_name,
      o.order_id,
      sum(od.unit_price*od.quantity*(1-od.discount)) as Total
from customers  as c
   left join orders as o
       on c.customer_id = o.customer_id
   left join order_details as od
       on  o.order_id = od.order_id
where o.order_date >='2016-01-01' and  o.order_date <='2016-01-31'
group by customer_id , c.company_name, order_id
having total > 10000;

-- 35. Month-end orders
/*
   At the end of the month, salespeople are likely to try much harder to get
   orders, to meet their month-end quotas. Show all orders made on the last
   day of the month. Order by EmployeeID and OrderID
*/

select
      e.employee_id,
      o.order_id,
      o.order_date
from employees as e
   left join orders as o
       on e.employee_id=o.employee_id
where order_date = last_day(order_date);

-- 36. Orders with many line items
/*
   The Northwind mobile app developers are testing an app that customers
   will use to show orders. In order to make sure that even the largest
   orders will show up correctly on the app, they'd like some samples of
   orders that have lots of individual line items. Show the 10 orders with
   the most line items, in order of total line items.
*/

select 
     o.order_id,
    count(product_id) as  Total_Order
from orders as o
   left join order_details as od
       on o.order_id = od.order_id
group by o.order_id
order by total_order desc limit 10;

-- 37. Orders - random assortment
/*
   The Northwind mobile app developers would now like to just get a
   random assortment of orders for beta testing on their app. Show a
   random set of 2% of all orders.
*/

select 
      order_id
from orders
order by uuid() limit 17;

-- 38. Orders - accidental double-entry
/*
   Janet Leverling, one of the salespeople, has come to you with a request.
   She thinks that she accidentally double-entered a line item on an order,
   with a different ProductID, but the same quantity. She remembers that
   the quantity was 60 or more. Show all the OrderIDs with line items that
   match this, in order of OrderID.
*/

select 
     Order_ID
from order_details
where quantity >= 60
group by Order_ID,Quantity
having count(*) > 1
order by order_id,quantity;

-- 39. Orders - accidental double-entry details
/*
   Based on the previous question, we now want to show details of the
   order, for orders that match the above criteria.
*/

with cte as (
               select 
					Order_ID
				from order_details
				where quantity >= 60
				group by Order_ID,Quantity
				having count(*) > 1
				order by order_id
			)
            
  select 
        order_id,
        product_id,
        unit_price,
        quantity
from order_details
where order_id in 
         (  select 
                  order_id 
		    from cte
		 )
order by order_id,quantity desc;

-- 40. Orders - accidental double-entry details, derived table
/* 
   Here's another way of getting the same results as in the previous
   problem, using a derived table instead of a CTE. However, there's a bug
   in this SQL. It returns 20 rows instead of 16. Correct the SQL.
   Problem SQL:
   Select OrderDetails.OrderID, ProductID, UnitPrice, Quantity, Discount
   From OrderDetails
   Join (  Select OrderID From OrderDetails Where Quantity >= 60
		   Group By OrderID, Quantity
           Having Count(*) > 1 ) 
   PotentialProblemOrders on PotentialProblemOrders.OrderID = OrderDetails.OrderID
   Order by OrderID, ProductID
*/

select 
       Order_Details.Order_ID, 
	   Product_ID, 
       Unit_Price, 
       Quantity, 
       Discount
   from Order_Details
      join (  
			   select 
					 distinct Order_ID 
				From Order_Details 
				where Quantity >= 60
				group by Order_ID, Quantity
				having count(*) > 1 
			)  PotentialProblemOrders 
	        on PotentialProblemOrders.Order_ID = Order_Details.Order_ID
   Order by Order_ID,quantity desc;
   
-- 41. Late orders
-- Some customers are complaining about their orders arriving late. Which orders are late?

select
      Order_ID as LateOrders_OrderID,
      Order_Date,
      Required_Date,
      Shipped_Date
from orders
where shipped_date >= required_date;

-- 42. Late orders - which employees?
/* 
   Some salespeople have more orders arriving late than others. Maybe
   they're not following up on the order process, and need more training.
   Which salespeople have the most orders arriving late?
*/

select
      e.Employee_ID,
      First_Name,
      Last_Name,
      count(*) as LateOrders
from orders as o
    join employees as e
        on o.employee_id = e.employee_id
where shipped_date >= required_date
group by Employee_ID, First_Name,Last_Name
order by LateOrders desc;

-- 43. Late orders vs. total orders
/*
   Andrew, the VP of sales, has been doing some more thinking some more
   about the problem of late orders. He realizes that just looking at the
   number of orders arriving late for each salesperson isn't a good idea. It
   needs to be compared against the total number of orders per
   salesperson. Return results like the following:
*/

with lateorders as 
(
      select 
            employee_id ,
            count(*)  as Total_Orders        
      from orders
	  where shipped_date > required_date
      group by employee_id
      
)

, totalorders as
(
     select
          employee_id,
         count(*) as Total_Orders
     from orders 
     group by employee_id
)

 select 
      e.employee_id,
      t.Total_Orders as Orders_In_Total,
	  l.Total_Orders as Late_Orders
from employees as e
   join totalorders as t
       on t.employee_id = e.employee_id
   join lateorders as l
       on l.employee_id = t.employee_id
order by Orders_In_Total desc;

-- 44. Late orders vs. total orders - missing employee
/*
   There's an employee missing in the answer from the problem above. Fix
   the SQL to show all employees who have taken orders.
*/

with lateorders as 
(
      select 
            employee_id ,
            count(*)  as Total_Orders        
      from orders
	  where  required_date <= shipped_date 
      group by employee_id
      
)

, totalorders as
(
     select
          employee_id,
         count(*) as Total_Orders
     from orders 
     group by employee_id
)

 select 
      e.employee_id,
      t.Total_Orders as Orders_In_Total,
	  l.Total_Orders as Late_Orders
from employees as e
    join totalorders as t
        on t.employee_id = e.employee_id
    join lateorders as l
        on l.employee_id = t.employee_id
order by Orders_In_Total desc;

-- 45. Late orders vs. total orders - fix null
/*
   Continuing on the answer for above query, let's fix the results for row 5
   - Buchanan. He should have a 0 instead of a Null in LateOrders.
*/

with lateorders as 
(
      select 
            employee_id ,
            count(*)  as Total_Orders
      from orders
	  where  shipped_date >= required_date
      group by employee_id
      
)

, totalorders as
(
     select
          employee_id,
         count(*) as Total_Orders
     from orders 
     group by employee_id
)

 select 
      e.employee_id,
      t.Total_Orders as Orders_In_Total,
	  l.Total_Orders as Late_Orders
from employees as e
   join totalorders as t
       on t.employee_id = e.employee_id
   join lateorders as l
       on l.employee_id = t.employee_id
order by case 
            when l.total_orders is null then 0 
	     else l.total_orders
         end desc
         , Orders_In_Total ;

-- 46. Late orders vs. total orders - percentage
-- Now we want to get the percentage of late orders over total orders.

with lateorders as 
(
      select 
            employee_id ,
            count(*)  as Total_Orders
      from orders
	  where  shipped_date >= required_date
      group by employee_id
      
)

, totalorders as
(
     select
          employee_id,
         count(*) as Total_Orders
     from orders 
     group by employee_id
)

select 
      e.employee_id,
      e.Last_Name,
      t.Total_Orders as Orders_In_Total,
	  l.Total_Orders as Late_Orders,
       -- (isnull(cast(l.Total_Orders as decimal)) * 1.00 )/ t.Total_Orders as Percenatge
       (l.Total_Orders  * 1.00) / t.Total_Orders as Percenatge
from employees as e 
   join totalorders as t
      on t.employee_id = e.employee_id
   join lateorders as l
      on l.employee_id = t.employee_id
order by case 
            when l.total_orders is null then 0 
	     else l.total_orders
         end 
         , Orders_In_Total ;

-- 47. Late orders vs. total orders - fix decimal
/*
   So now for the PercentageLateOrders, we get a decimal value like we
   should. But to make the output easier to read, let's cut the
   PercentLateOrders off at 2 digits to the right of the decimal point.
*/

with lateorders as 
(
      select 
            employee_id ,
            count(*)  as Total_Orders
      from orders
	  where  shipped_date >= required_date
      group by employee_id
      
)

, totalorders as
(
     select
          employee_id,
         count(*) as Total_Orders
     from orders 
     group by employee_id
)

select 
      e.employee_id,
      e.Last_Name,
      t.Total_Orders as Orders_In_Total,
	  l.Total_Orders as Late_Orders,
	  cast((l.Total_Orders  * 1.00) / t.Total_Orders as decimal(10,2))as Percenatge
from employees as e 
   join totalorders as t
      on t.employee_id = e.employee_id
   join lateorders as l
     on l.employee_id = t.employee_id
order by case 
            when l.total_orders is null then 0 
	     else l.total_orders
         end 
         , Orders_In_Total ;

-- 48. Customer grouping
/* 
   Andrew Fuller, the VP of sales at Northwind, would like to do a sales
   campaign for existing customers. He'd like to categorize customers into
   groups, based on how much they ordered in 2016. Then, depending on
   which group the customer is in, he will target the customer with
   different sales materials.
   The customer grouping categories are 0 to 1,000, 1,000 to 5,000, 5,000
   to 10,000, and over 10,000.
   A good starting point for this query is the answer from the problem
   “High-value customers - total orders. We don’t want to show customers
   who don’t have any orders in 2016.
   Order the results by CustomerID.
*/

select 
      c.Customer_ID,
      c.Company_Name,
	  sum(od.unit_price*od.quantity) as Total_Amount,
      case 
           when  sum(od.unit_price*od.quantity) between 0 and 1000 then "Low"
           when  sum(od.unit_price*od.quantity) between 1001 and 5000 then "Medium"
		   when  sum(od.unit_price*od.quantity) between 5001 and 10000 then "High"
		   when  sum(od.unit_price*od.quantity) > 10001 then "Very High"
	  end as Customer_Group
from customers  as c
    left join orders as o
       on c.customer_id = o.customer_id
    left join order_details as od
       on  o.order_id = od.order_id
-- where order_date between '2016-01-01' and  '2016-12-31'
group by c.Customer_ID,c.Company_Name;

-- 49. Customer grouping - fix null
/*
   There's a bug with the answer for the previous question. The
   CustomerGroup value for one of the rows is null.
   Fix the SQL so that there are no nulls in the CustomerGroup field.
*/

select 
      c.Customer_ID,
      c.Company_Name,
	  sum(od.unit_price*od.quantity) as Total_Amount,
      case 
           when  sum(od.unit_price*od.quantity) > 0 and sum(od.unit_price*od.quantity) <= 1000 then "Low"
           when  sum(od.unit_price*od.quantity) > 1001 and sum(od.unit_price*od.quantity) <= 5000 then "Medium"
		   when  sum(od.unit_price*od.quantity) > 5001 and sum(od.unit_price*od.quantity) <= 10000 then "High"
		   when  sum(od.unit_price*od.quantity) > 10001 then "Very High"
           when  sum(od.unit_price*od.quantity) is null then "Low"
	  end as Customer_Group
from customers  as c
    left join orders as o
       on c.customer_id = o.customer_id
    left join order_details as od
    on  o.order_id = od.order_id
-- where order_date between '2016-01-01' and  '2016-12-31'
group by   c.Customer_ID,c.Company_Name;

-- 50. Customer grouping with percentage
/*
   Based on the above query, show all the defined CustomerGroups, and
   the percentage in each. Sort by the total in each group, in descending
   order.
*/
      
with cte as(
select 
      c.Customer_ID,
      c.Company_Name,
	  sum(od.unit_price*od.quantity) as Total_Amount,
      case 
           when  sum(od.unit_price*od.quantity) > 0 and sum(od.unit_price*od.quantity) <= 1000 then "Low"
           when  sum(od.unit_price*od.quantity) > 1001 and sum(od.unit_price*od.quantity) <= 5000 then "Medium"
		   when  sum(od.unit_price*od.quantity) > 5001 and sum(od.unit_price*od.quantity) <= 10000 then "High"
		   when  sum(od.unit_price*od.quantity) > 10001 then "Very High"
           when  sum(od.unit_price*od.quantity) is null then "Low"
	  end as Customer_Group
from customers  as c
   left join orders as o
       on c.customer_id = o.customer_id
   left join order_details as od
    on  o.order_id = od.order_id
-- where order_date between '2016-01-01' and  '2016-12-31'
group by c.Customer_ID,c.Company_Name
)

select 
      Customer_Group,
      count(*) as Total,
      count(*) * 1.0/ (select count(*) from cte) as Percentage
from cte
group by  Customer_Group
order by total desc;

-- 51. Customer grouping - flexible
/*
   Andrew, the VP of Sales is still thinking about how best to group
   customers, and define low, medium, high, and very high value
   customers. He now wants complete flexibility in grouping the
   customers, based on the dollar amount they've ordered. He doesn’t want
   to have to edit SQL in order to change the boundaries of the customer
   groups.
   How would you write the SQL?
   There's a table called CustomerGroupThreshold that you will need to
   use. Use only orders from 2016.
*/

with cte as(
select 
      c.Customer_ID,
      c.Company_Name,
	  sum(od.unit_price*od.quantity) as Total_Amount,
      case 
           when  sum(od.unit_price*od.quantity) > 0 and sum(od.unit_price*od.quantity) <= 1000 then "Low"
           when  sum(od.unit_price*od.quantity) > 1001 and sum(od.unit_price*od.quantity) <= 5000 then "Medium"
		   when  sum(od.unit_price*od.quantity) > 5001 and sum(od.unit_price*od.quantity) <= 10000 then "High"
		   when  sum(od.unit_price*od.quantity) > 10001 then "Very High"
           when  sum(od.unit_price*od.quantity) is null then "Low"
	  end as Customer_Group
from customers  as c
   left join orders as o
       on c.customer_id = o.customer_id
   left join order_details as od
       on  o.order_id = od.order_id
-- where order_date between '2016-01-01' and  '2016-12-31'
group by   c.Customer_ID,c.Company_Name
)

select
	  a.Customer_ID,
      a.Company_Name,
      b.Total_Amount,
      b.Customer_Group
from cte a , cte b
where a.total_amount = b.total_amount
order by customer_id;

-- 52. Countries with suppliers or customers
/*
   Some Northwind employees are planning a business trip, and would like
   to visit as many suppliers and customers as possible. For their planning,
   they’d like to see a list of all countries where suppliers and/or customers
   are based.
*/

select 
     distinct Country,
     "Customers" as Customer_OR_Supplier
from customers
union
select 
      distinct Country,
      "Suppliers" as Customer_OR_Supplier
from suppliers;

-- 53. Countries with suppliers or customers, version 2
/*
   The employees going on the business trip don’t want just a raw list of
   countries, they want more details. We’d like to see output like the
   below, in the Expected Results.
*/

with customerscountry as
(  
	select 
          distinct Country
     from customers
),

 supplierscountry as
(
   select 
      distinct Country
  from suppliers
)

select c.country as Customers_Country,
      s.Country as Suppliers_Country
from supplierscountry as s
   right join customerscountry as c
       on s.country = c.country
order by Customers_Country,Suppliers_Country;

-- 54. Countries with suppliers or customers - version 3
/*
   The output of the above is improved, but it’s still not ideal
   What we’d really like to see is the country name, the total suppliers, and
   the total customers.
*/

with suppliercountry as
(
    select
          country,
          count(*) as TotalCount
	from suppliers
	group by country
),

 customercountry as
(
    select
          country,
          count(*) as TotalCount
	from customers
	group by country
)
  
select
     s.country as Supplier_Country_Name,
     c.country as Customer_Country_Name,
     s.TotalCount as Suppliers_Count,
     c.TotalCount as Customers_Count
from suppliercountry as s
   left join customercountry as c
        on s.country = c.country
order by s.country , c.country ;
  
-- 55. First order in each country
/*
   Looking at the Orders table—we’d like to show details for each order
   that was the first in that particular country, ordered by OrderID.
   So, we need one row per ShipCountry, and CustomerID, OrderID, and
   OrderDate should be of the first order from that country.
*/

with firstorder as(
select 
     Ship_Country,
     Customer_ID,
     Order_ID,
     Order_Date,
     row_number() over (partition by ship_country order by ship_country,order_id) as FirstRow
from orders
)

select 
     Ship_Country,
     Customer_ID,
     Order_ID,
     Order_Date
from firstorder
where Firstrow = 1
order by ship_country;
     
-- 56. Customers with multiple orders in 5 day period
/* 
   There are some customers for whom freight is a major expense when
   ordering from Northwind.
   However, by batching up their orders, and making one larger order
   instead of multiple smaller orders in a short period of time, they could
   reduce their freight costs significantly.
   Show those customers who have made more than 1 order in a 5 day
   period. The sales people will use this to help customers reduce their
   costs.
   Note: There are more than one way of solving this kind of problem. For
   this problem, we will not be using Window functions.
*/

with firstorder as(
select 
     Customer_ID,
     Order_ID,
     Order_Date,
     row_number() over (partition by customer_id order by customer_id,order_date) as RowNumber
from orders
),

 nextorder as(
select 
     Customer_ID,
     Order_ID,
     Order_Date,
     row_number() over (partition by customer_id order by customer_id,order_date) as RowNumber
from orders
)

select 
     f.Customer_ID,
     f.Order_ID as Intial_Order_ID,
     f.Order_Date as Initial_Order_Date,
     n.Order_ID as Next_Order_ID,
     n.Order_Date as Next_Order_Date,
     datediff(n.Order_date , f.Order_date) as Days_Between
from firstorder as f
   left join nextorder as n
         on f.customer_id = n.customer_id
where f.order_id < n.order_id and   datediff(n.Order_date , f.Order_date)  <  5 
order by f.customer_id , f.order_id;

-- 57. Customers with multiple orders in 5 day period, version 2
/*
   There’s another way of solving the problem above, using Window
   functions. We would like to see the following results.
*/

WITH  firstorder as(
select 
     Customer_ID,
     Order_ID,
     Order_Date,
     row_number() over (partition by customer_id order by customer_id,order_date) as RowNumber
from orders
),

 nextorder as(
select 
     Customer_ID,
     Order_ID,
     Order_Date,
     lead(order_date,1) over (partition by customer_id order by customer_id,order_date) as RowNumber
from orders
)

select 
     f.Customer_ID,
     f.Order_ID as Intial_Order_ID,
     f.Order_Date as Initial_Order_Date,
     n.Order_ID as Next_Order_ID,
     n.Order_Date as Next_Order_Date,
     datediff( n.Order_date , f.Order_date ) as Days_Between
from firstorder as f
   left join nextorder as n
         on f.customer_id = n.customer_id
where f.order_id < n.order_id and   datediff(  n.Order_date , f.Order_date )  < 5 
order by f.customer_id , f.order_id;