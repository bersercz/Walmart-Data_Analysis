select * from walmart;

drop table walmart;


select count(*) from walmart;

select 
	distinct payment_method,
	count(*)
	from walmart
	group by 1;

select	
	count(distinct branch)
	from walmart;

select min(quantity) from walmart


-- Business Analysis

-- 1 Find the different payment method and number of transactions, number of qty sold.


select 
	payment_method,
	count(*) as no_payment,
	sum(quantity) as no_qty_sold
	from walmart
	group by 1


-- 2 Identify the highest-rated category in each branch, displaying the branch, category and avg rating


select 
	branch,
	category,
	avg(rating) as avg_rating,
	rank() over(partition by branch order by avg(rating) desc ) as rank
	from walmart
	group by 1, 2


-- 3 identify the busiest day for each branch based on the number of transactions


select * 
from
(select 
	branch,
	to_char(to_date(date, 'DD/MM/YY'), 'Day') as day_name,
	count(*) as no_transactions,
	rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by 1, 2
	)
where rank = 1


-- 4 Calculate the total quantity of items sold per payment maehtod. list payment_method and total_quantity.


select 
	payment_method,
	sum(quantity) as no_qty_sold
	from walmart
	group by 1


-- 5 Determine the avg, minimum, and max rating of category for each city. List the city, average_rating, min_rating, and max_rating.


select 
	category,
	city,
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
	from walmart
	group by 1, 2


-- 6 Calculate the total profit for each ctegory by considering total_profit as(unit_price * quantity * profit_margin).
--   List category and total_profit, ordered from highest to lowest profit.

select 
	category,
	sum(total * profit_margin) as profit,
	sum(total) as total_revenue
	from walmart
	group by 1


-- 7 Determine the msot common payment method for each Branch, Display Branch and the preferred_oayment_method.

with city
as(
select
	branch,
	payment_method,
	count(*) as total_trans,
	rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by 1, 2
)
select * from city
where rank = 


-- 8 categorise sales into 3 groups morning, afternon, evening. Find out which of the shift and number of invoices.


select 
	branch,
case
	when extract(hour from (time::time))< 12 then 'Morning'
	when extract(hour from (time:: time))between 12 and 17 then 'Afternoon'
	else 'Evening'
	end day_time,
	count(*)
	from walmart
	group by 1, 2
	order by 1, 3 desc


-- 9 Identify 5 branch with highest descrease ratio in rvenue compare to last year (current year as 2023 and last year as 2022)


with revenue_2022
as
(
select 	 
	branch,
	sum(total) as revenue
	from walmart
	where extract(year from to_date(date, 'DD/MM/YY')) = 2022
	group by 1),

revenue_2023
as
(
select 	 
	branch,
	sum(total) as revenue
	from walmart
	where extract(year from to_date(date, 'DD/MM/YY')) = 2023
	group by 1)

select
	last_year.branch,
	last_year.revenue as current_year_revenue,
	current_year.revenue as current_year_revenue,
	round((last_year.revenue - current_year.revenue)::numeric/last_year.revenue::numeric*100, 2) as revenue_dec_ratio
from revenue_2022 as last_year
join 
revenue_2023 as current_year
on last_year.branch = current_year.branch
where 
	last_year.revenue > current_year.revenue
	order by 4 desc
	limit 5