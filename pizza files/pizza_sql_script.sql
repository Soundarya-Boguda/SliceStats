-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(ROUND(SUM(p.price * od.quantity), 2) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
                FROM
                    orders_details AS od
                        JOIN
                    pizzas AS p ON od.pizza_id = p.pizza_id) * 100,
            2) AS revenue_percentage
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over time.
select order_date,sum(total_revenue) over (order by order_date) as cum_revenue
from 
(select o.order_date, round(sum(p.price*od.quantity),2) as total_revenue
from orders as o
join orders_details as od 
on o.order_id=od.order_id
join pizzas as p
on od.pizza_id=p.pizza_id
group by  o.order_date) as sales 
limit 5;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, category, rnk, total_revenue
from (select category, name,total_revenue,
rank() over (partition by category order by total_revenue desc) as rnk
from 
(select pt.category,pt.name, round(sum(p.price*od.quantity),2) as total_revenue
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join orders_details as od
on p.pizza_id=od.pizza_id
group by pt.category, pt.name) as tr) as new_table
where rnk<=3



