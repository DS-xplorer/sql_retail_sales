----check the trend change over time

select
DATETRUNC(month,sale_date),
sum(total_sale) as total_Sales,
sum(quantiy) as total_quantity,
count(transactions_id) as no_of_sales,
count(distinct customer_id) as total_customer
from Retail_Sales
group by DATETRUNC(month,sale_date)

----cumulative analysis

select
sales_date,
total_sales,
sum(total_sales) over(order by sales_date) as running_profit,
avg(avg_price) over(partition by sales_date order by sales_date) as running_avg
from
(
select
DATETRUNC(month,sale_date) as sales_date,
sum(total_Sale) as total_sales,
avg(price_per_unit) as avg_price
from Retail_Sales
group by DATETRUNC(month,sale_date)
)t


---performance analysis

with monthly_category_Sales as(

select
DATETRUNC(month,sale_date) as date,
category,
sum(total_sale) as current_sales
from Retail_Sales
group by DATETRUNC(month,sale_date),category
)

select
date,
category,
current_sales,
avg(current_sales) over(partition by category) as avg_sales,
current_sales-avg(current_sales) over(partition by category) as diff_avg,
case when avg(current_sales) over(partition by category)<0 then 'below average'
	when avg(current_sales) over(partition by category)>0 then 'above average'
	else 'average'
end avg_change,
lag(current_Sales) over(partition by category order by date) as prv_sales,
current_Sales-lag(current_Sales) over(partition by category order by date) as diff_previous,
case when current_Sales-lag(current_Sales) over(partition by category order by date)>0 then 'increase'
	when current_Sales-lag(current_Sales) over(partition by category order by date)<0 then 'decrease'
	else 'no change'
end sales_change
from monthly_category_Sales
order by category


-----part to whole analysis
 
 with category_sales as (
 select
 category,
 sum(total_Sale) as total_Sales
 from Retail_Sales
 group by category)

 select
 category,
 total_sales,
 sum(total_sales) over () as hall_total_sale,
 concat(round((cast(total_sales as float)/sum(total_sales) over ())*100,2),'%') as total_percentage
 from category_sales


 -----data segmentation

 with customer_segment as (
 select
 customer_id,
 max(sale_date) as last_order,
 min(Sale_date) as first_order,
 sum(total_Sale) as total_spending
 from Retail_Sales
 group by customer_id),

 customer_life as (
 select 
 customer_id,
 last_order,
 life_span,
 total_spending,
 case when life_span>=20 then 'VIP_regular'
	when life_span <=12 then 'regular'
	else'new_customer'
end customer_seg
from(
select
 customer_id,
 last_order,
 total_spending,
 DATEDIFF(month,first_order,last_order) as life_span
 from customer_segment )t
 )
 select
 customer_seg,
 count(customer_id) as total_customers
 from customer_life
 group by customer_seg


 -----end of project