# 🗄️ eCommerce Database Analysis with SQL

## Project Background 📑

<details> 
<summary>
Project Background 
	
</summary>
<br>
You've been hired as an eCommerce Database Analyst for Maven Fuzzy Factory, an online retailer which has just launched its first product.

Maven Fuzzy Factory has been live for ~8 months, and your CEO is due to present company performance metrics to the board next week. 

You will extract and analyze website traffic and performance data from the Maven Fuzzy Factory database to quantify the company’s growth and tell the story of how you have been able to generate that growth.

</details> 
	
***

## The Database 🖇️
<details>
<summary>
Click here to see the ERD and snapshot of each table!
</summary>

<kbd><img src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/erd1.png" alt="Image" width="750" height="480"></kbd>

`orders` - Records consist of customers' orders with order id, time when the order is created, website session id, user id, product id of item ordered, number of items purchased, the price of the product (revenue), and cogs (cost of goods sold) in USD

<kbd><img width="659" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/orders.PNG"></kbd>

`products` - Records consist of products available with product id, time when the product is created, and product name

<kbd><img width="330" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/products.PNG"></kbd>

`website_sessions` - Records consist of each website session. This table shows where the traffic is coming from.

<kbd><img width="792" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/website_sessions.PNG"></kbd>

`website_pageviews` - The table that shows website pageviews and url of each pageview.

<kbd><img width="427" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/website_pageviews.PNG"></kbd>

`order_items`

<kbd><img width="531" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/order_items.PNG"></kbd>

`order_item_refunds`

<kbd><img width="527" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/order_item_refunds.PNG"></kbd>
	
</details>

***
 
## Project Goal 🎯

<details> 
<summary>
Project Goal 
	
</summary>
<br>

<kbd><img width="294" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/project_questions.PNG"></kbd>

**Objectives**

- Tell the story of the company's growth, using trended performance data
- Use the database to explain some of the details around the company's growth story
- Analyze current performance and use the data available to assess upcoming opportunities

**Problem Questions**

1. Gsearch seems to be the biggest driver of our busienss. Could you pull **monthly trends** for **gsearch sessions and orders** so that we can showcase the growth there?

2. Next, it would be great to see a similar trend for gsearch, but this time **splitting out nonbrand and brand campaigns separately**. I am wondering if brand is picking up at all. If so, this is a good story to tell.

3. While we're on gsearch, could you dive into nonbrand, and pull **monthly sessions and orders split by device type**? I want to flex our analytical muscles a little and show the board we really know our traffic sources.

4. I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from gsearch. Can you pull **monthly trends for gsearch, alongside monthly trends for each of our other channels?**

5. I'd like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull **session to order conversion rates, by month**?

6. For the gsearch lander test, please **estimate the revenue that test earned us** (**Hint:** Look at the increase in CVR from the test (JUn 19 - Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)

7. For the landing page test you analyzed previously, it would be great to shows a **full conversion funnel from each of the two pages to orders**. You can use the same time period you analyzed last time (Jun 19 - Jul 28).

8. I'd love for you to **quantify the impact of our billing test**, as well. Please analyze the lift generated from the test (Sep 10 - Nov 10), in terms of **revenue per billing page sessions**, and then pull the number of billing page sessions for the past month to understand monthly impact.

***

</details> 

## Insight and Visualization 📈

### ✒ Q1: Gsearch seems to be the biggest driver of our busienss. Could you pull **monthly trends** for **gsearch sessions and orders** so that we can showcase the growth there?

```sql
SELECT
  EXTRACT(YEAR_MONTH FROM website_sessions.created_at) AS yearmonth,
  COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(COUNT(DISTINCT order_id) /
    COUNT(DISTINCT website_sessions.website_session_id) * 100.0, 2) AS conversion_rate
FROM website_sessions
  LEFT JOIN orders
  ON website_sessions.website_session_id = orders.website_session_id
WHERE utm_source = 'gsearch'
  AND website_sessions.created_at < '2012-11-27'
GROUP BY 1;
```

<kbd><img width="241" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_1.PNG"></kbd>

<kbd><img width="541" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/charts/question_1_chart.png"></kbd>

### ✒ Q2: Next, it would be great to see a similar trend for gsearch, but this time **splitting out nonbrand and brand campaigns separately**. I am wondering if brand is picking up at all. If so, this is a good story to tell.

***


