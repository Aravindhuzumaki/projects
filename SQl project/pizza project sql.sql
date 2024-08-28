create schema pizza;
use pizza;
select * from order_details;
select * from orders;
select * from pizza_types;

-- Total num of order placed 
select distinct count(order_id) from orders;

-- total revenue and view 
select order_details.pizza_id,order_details.quantity,pizzas.price from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id;

select cast(sum( order_details.quantity * pizzas.price)as decimal(10,2)) as "total revenue"  from  order_details join pizzas on order_details.pizza_id = pizzas.pizza_id;

-- highest pizza price 
select pizza_types.name as "pizza name", cast(pizzas.price as decimal ( 10 , 2) ) as "price" from pizzas join pizza_types on pizza_types order by price desc limit 1 ;

with cte as ( select pizza_types.name as "pizza_name" , cast( pizzas.price as decimal ( 10 , 2)) as "price", rank() over ( order by price desc) as rnk from pizzas 
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id )
select pizza_name, price from cte where rnk = 1;

-- most common pizza size ordered
select pizzas.size , count(distinct order_id )  as "no of orders" , sum(quantity) as " total no of quantity" from order_details 
join pizzas on  order_details.pizza_id = pizzas.pizza_id 
group by  pizzas.size order by count(distinct order_id ) desc;

-- top 5 most ordered pizza
select pizza_types.name as "pizza" , sum(quantity) as "total no of quantity" from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
group by pizza_types.name order by sum(quantity) desc limit 5 ;

-- top category pizza 
select pizza_types.category as "pizza size",sum(quantity) as "total quantity" from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
group by pizza_types.category order by sum(quantity) desc limit 5 ;

-- order by hour of the day
select hour(time), count(distinct order_id) from orders 
group by hour(time) order by count(distinct order_id);

-- category wise pizza distribution
select category , count(distinct pizza_type_id) from pizza_types
 group by category order by count(distinct pizza_type_id);

-- average number of pizzas order per day
with cte as (
select orders.date , sum(order_details.quantity) as "total_pizza" from order_details 
join orders on orders.order_id =order_details.order_id 
group by orders.date
)
select avg(total_pizza) from cte;

-- top 3 most ordered pizza 
select pizza_types.name , sum(order_details.quantity * pizzas.price) as "revenue_from_pizza" from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id 
group by pizza_types.name 
order by (revenue_from_pizza) desc limit 5 ;

-- percentage contribution of each pizza to total revenue 
select pizza_types.name , concat(cast((sum( order_details.quantity * pizzas.price) 
/
(select sum( order_details.quantity * pizzas.price) from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id )) * 100 as decimal (10, 2)),"%" )  as "revenue_contributed_to_pizza" from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id 
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
group by pizza_types.name order by (revenue_contributed_to_pizza)

-- cumulative revenue generated over time 

with cte as (
select date as "date" ,cast(sum( order_details.quantity * pizzas.price) as decimal (10 ,2)) as "revenue" from order_details
 join orders on order_details.order_id = orders.order_id
 join pizzas on pizzas.pizza_id=order_details.pizza_id 
 group by (date)
)
select date, revenue , sum(revenue) over (order by date ) as "cumulative sum"
from cte 
group by date , revenue 

-- top 3 most ordered pizza types based on revenue for each pizza category
with cte as ( 
select category,name , cast(sum(quantity*price) as decimal (10,2)) as revenue from order_details 
join pizzas on pizzas.pizza_id=order_details.pizza_id 
join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id 
group by category,name 
),
 cte1 as
 (select category,name,revenue, 
 rank() over( partition by category order by revenue desc ) as rnk 
 from cte)
 select category,name,revenue from cte1 
 where rnk in (1,2,3) order by name, category,revenue; 







