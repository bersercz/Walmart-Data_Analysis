# Walmart Data Analysis

# About Dataset
###  The dataset represents Walmart’s day-to-day retail activity, including:
### Sales information: invoices, product categories, unit prices, quantity sold, and revenue.
### Customer behavior: payment methods, transaction timings, and product ratings.
### Branch and city details: enabling cross-location performance comparison.
### By cleaning and structuring the dataset, it was made suitable for deeper business analysis in PostgreSQL.


# Data Wrangling using Pandas
```python
data.shape
data.info()
data.describe()
data.isnull().sum()
data[data.duplicated()]
data.drop_duplicates(keep = 'first', inplace = True)
data.dropna(inplace = True)
data['unit_price'] = data['unit_price'].str.replace('$', '' ).astype(float)
data.unit_price.dtype
data['total'] = data['unit_price'] * data['quantity']
data.columns= data.columns.str.lower()
```
## Transfer of Dataset To Postgresql
```python
engine_psql = create_engine("postgresql+psycopg2://database-name:password@localhost:5432/folder_name")
try:
    engine_psql
    print('Connection Successful to PSQL')
except: 
    print('Unable to Connect')

data.to_sql(name = 'walmart', con = engine_psql, if_exists ='append', index = False)
```

# Problem Statement & Solutions

### 1 Find the different payment method and number of transactions, number of qty sold.

```sql
select 
	payment_method,
	count(*) as no_payment,
	sum(quantity) as no_qty_sold
	from walmart
	group by 1
```

### 2 Identify the highest-rated category in each branch, displaying the branch, category and avg rating

```sql
select 
	branch,
	category,
	avg(rating) as avg_rating,
	rank() over(partition by branch order by avg(rating) desc ) as rank
	from walmart
	group by 1, 2
```

### 3 identify the busiest day for each branch based on the number of transactions.

```sql
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
```

### 4 Calculate the total quantity of items sold per payment maehtod. list payment_method and total_quantity.

```sql
select 
	payment_method,
	sum(quantity) as no_qty_sold
	from walmart
	group by 1
  ```

### 5 Determine the avg, minimum, and max rating of category for each city. List the city, average_rating, min_rating, and max_rating.

```sql
select 
	category,
	city,
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
	from walmart
	group by 1, 2
  ```

### 6 Calculate the total profit for each ctegory by considering total_profit as(unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit.

```sql
select 
	category,
	sum(total * profit_margin) as profit,
	sum(total) as total_revenue
	from walmart
	group by 1
```

### 7 Determine the msot common payment method for each Branch, Display Branch and the preferred_payment_method.

```sql
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
where rank = 1
```

### 8 categorise sales into 3 groups morning, afternon, evening. Find out which of the shift and number of invoices.

```sql
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
```

### 9 Identify 5 branch with highest descrease ratio in rvenue compare to last year (current year as 2023 and last year as 2022).

```sql
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
```


# 🔑 Key Findings (Business Insights)

### Customers prefer specific payment methods, though preferences vary by branch.

### Customer satisfaction levels differ by product category and city, with clear leaders in quality perception.

### Sales peak during afternoons and evenings, highlighting the need for optimized staffing and inventory.

### A few categories generate disproportionate profits, driven by both demand and margins.

### Some branches experienced revenue decline compared to the previous year, requiring management attention.


 

# 🏢 Conclusions

### Branch-level strategies are more effective than one-size-fits-all decisions.

### High-rated categories should be promoted, while lower-rated ones require improvement.

### Operational efficiency can be improved by aligning manpower and stock with peak shopping times.

### Revenue risk management is critical for branches facing year-on-year decline.

### Walmart can achieve sustainable growth by balancing profitability with customer satisfaction.



# _________________________________________________________________________________________________________________________________
## By: Devansh Singh Tomar
