Select * from walmart;

SELECT COUNT(*) FROM walmart;

-- Business problems
-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method

SELECT 
	payment_method,
    COUNT(*) as no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method 
order by Count(*) desc;


-- Question #2: Identify the highest-rated category in each branch .Display the branch, category, and avg rating

SELECT *
FROM
(SELECT 
	branch,
    category,
    AVG(rating) as avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rnk
from walmart
GROUP BY 1,2
) as ranked
WHERE rnk=1;


-- Q3: Identify the busiest day for each branch based on the number of transactions

Select * From(
Select 
	branch,
    dayname(str_to_date(date,'%d%m%Y')) as day_name,
    COUNT(*) as no_transactions,
    Rank() over(partition by branch ORDER BY COUNT(*) DESC) as rnk
From walmart
group by branch,day_name
) as ranked
where rnk=1;


-- Q4: Calculate the total quantity of items sold per payment method

SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;


-- Q5: Determine the average, minimum, and maximum rating of categories for each city

SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;


-- Q6: Calculate the total profit for each category

SELECT 
    category,
    round(SUM(unit_price * quantity * profit_margin),2) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- Q7: Determine the most common payment method for each branch

WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rnk = 1;


-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    case
		when HOUR(TIME(time))<12 Then 'Morning'
		when HOUR(TIME(time))Between 12 AND 17 Then 'Afternoon'
		ELSE 'Evening'
    END as shift,
    COUNT(*) as num_invoices
FROM walmart
GROUP BY branch,shift
ORDER BY branch, num_invoices DESC;


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS(
	SELECT
		branch,
        SUM(total) as revenue
	FROM walmart
    WHERE YEAR(str_to_date(date,'%d/%m/%Y')) = 2022
    GROUP BY branch
    ),
revenue_2023 as(
 SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
    )
    
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
 