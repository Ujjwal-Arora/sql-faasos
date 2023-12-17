drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2021 21:30:45','25km','25mins',null),
(8,2,'01-10-2021 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2021 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

--1. How many rolls were ordered ?
select count(roll_id)
from customer_orders;

--2. How many unique customers are made ?
select count(distinct customer_id)
from customer_orders;

--3. How many successful order delivered by each driver ?
select driver_id,count(*)
from driver_order
WHERE cancellation not in ('Customer Cancellation','Cancellation')
group by driver_id


--4.How many of each type of roll was delivered ?
with cte as ( select *,case when cancellation in ('Customer Cancellation','Cancellation') then 0
			  else 1
			  end as order_status
			from driver_order)
select roll_id,count(*)
from customer_orders as co 
join cte 
on co.order_id=cte.order_id
where order_status=1
group by roll_id
--cancellation column was not readable due to NULL values so i created another column to distinguish between the cancelled & non cancelelled orders
--used different approach in Q10

--5. How many Veg & Nonveg rolls were ordered by each customer ?
with cte as ( select *,case when cancellation in ('Customer Cancellation','Cancellation') then 0
			  else 1
			  end as order_status
			from driver_order)
select roll_name,count(*)
from customer_orders as co 
join cte 
on co.order_id=cte.order_id
join rolls
on co.roll_id=rolls.roll_id
where order_status=1
group by roll_name


--6. What was the maximum number of rolls delivered in a single order ?
select top 1 order_id,COUNT(*) as number_of_rolls
from customer_orders
group by order_id
order by number_of_rolls desc


--7. For each customer,How many Deliverd roles had at least one change and how many had no changes? 
with new_customer_orders as (select * ,case when  not_include_items is null then 'No'
												when not_include_items='' then 'No'
												else 'Yes'
												end as changes_in_include,
											case when  extra_items_included is null then 'No'
												when extra_items_included='' then 'No'
												when extra_items_included='NaN' then 'No'
												else 'Yes'
												end as changes_in_extra
								from customer_orders),
changes_customer_orders as(select *, case when changes_in_include ='No' and changes_in_extra ='No' then 'No'
											else 'Yes'
											end as total_changes
							from new_customer_orders),
new_driver_order as ( select *,case when cancellation in ('Customer Cancellation','Cancellation') then 'not delivered'
			  else 'delivered'
			  end as delivery_status
			from driver_order)
select customer_id,COUNT(*)
from changes_customer_orders as cco
join new_driver_order as ndo
on cco.order_id=ndo.order_id
where delivery_status='delivered'
group by customer_id,total_changes





--8.How many rolls were delivered that had both exclusions and extras?

with new_customer_orders as (select * ,case when  not_include_items is null then 'No'
												when not_include_items='' then 'No'
												else 'Yes'
												end as changes_in_include,
											case when  extra_items_included is null then 'No'
												when extra_items_included='' then 'No'
												when extra_items_included='NaN' then 'No'
												else 'Yes'
												end as changes_in_extra
								from customer_orders),
changes_customer_orders as(select *, case when changes_in_include ='No' and changes_in_extra ='No' then 'No'
											else 'Yes'
											end as total_changes
							from new_customer_orders),
new_driver_order as ( select *,case when cancellation in ('Customer Cancellation','Cancellation') then 'not delivered'
			  else 'delivered'
			  end as delivery_status
			from driver_order)
select count(*) as [rolls with exclusions and extras]
from changes_customer_orders as cco
join new_driver_order as ndo
on cco.order_id=ndo.order_id
where delivery_status='delivered' and changes_in_include='Yes' and changes_in_extra='Yes'






--9.What are the total number of roles ordered for each hour of the day? 
select concat(datepart(hour,order_date),'-',datepart(hour,order_date)+1) as hour,count(*) as [number of roles]
from customer_orders
group by datepart(hour,order_date)



--10.What was the number of orders for each day of the week? 
select  datename(dw,order_date) as day,count(distinct order_id) as [numbers of orders]
from customer_orders
group by datename(dw,order_date)



--11.What was the average time in minutes it took for each driver to arrive at Faasos HQ to pick up the order? 
select driver_id,avg(datediff(minute,order_date,pickup_time)) as avg_diff
from customer_orders co join driver_order do
on co.order_id=do.order_id
where pickup_time is not null
group by driver_id




--12.Is there any relationship between the number of roles and how long the order takes to prepare?
select COUNT(*) as [number of roles],DATEDIFF(minute,order_date,pickup_time) as time_diff
from customer_orders co join driver_order do
on co.order_id=do.order_id
where pickup_time is not null
group by co.order_id,DATEDIFF(minute,order_date,pickup_time)
order by time_diff desc




--13.What was the average distance travelled for each customer?
with cte as (select *,cast(replace(distance,'km','') as decimal(4,2))  as dist
from driver_order 
where pickup_time is not null)
select  customer_id,avg(dist) as [average distance travelled]
from cte join customer_orders co
on co.order_id=cte.order_id
group by customer_id






--14.What was the difference between the longest and the shortest delivery for all orders? 
select cast(max(duration) as int)-cast(replace(min(duration),'minutes','') as int) as diff
from driver_order






--15.What was the average speed for each driver for each delivery and do you notice any trend for these values? 
with cte as (select *,cast(trim(replace(distance,'km','')) as decimal(4,2)) as dist,cast(trim(replace(replace(replace(duration,'minutes',''),'minute',''),'mins',''))as decimal(4,2)) as dur
from driver_order
where pickup_time is not null)
select driver_id,dist/dur as speed_in_kmpm
from cte 
order by speed_in_kmpm desc
--or could have just used substring(duration,1,2) for duration
--substring(duration,1,CHARINDEX('m',duration)-1) will not work because 'm' is not present in all rows so where it is not present then charindex will give 0 i.e 0-1 is not defined in sql

--2nd solution 
with cte as (select *,cast(trim(replace(distance,'km','')) as decimal(4,2)) as dist,case when duration like '%m%' then cast(substring(duration,1,CHARINDEX('m',duration)-1) as decimal(4,2)) 
																					else cast(duration as decimal(4,2) )
																					end as dur
			from driver_order
			where pickup_time is not null)
select driver_id,dist/dur as speed_in_kmpm
from cte 
order by speed_in_kmpm desc



--16.What is the successful delivery percentage for each driver?
with cte as (select *,case when pickup_time is null then 0
			else 1
			end as delivery_status
			from driver_order)
select driver_id,sum(delivery_status)*100/count(*) as [successful delivery percentage]
from cte
group by driver_id


--used this data bcz the data had alot of irregulaties and required alot of cleaning & modifying