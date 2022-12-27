# eCommerce Database Analysis with SQL

<p align="center">
  <img src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/ecommerce_cover.jpg" width="400" height="250" />

## Project Background

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

## The Database
<details>
<summary>
Click here to see the ERD and snapshot of each table!
</summary>

<p align="center">
<kbd><img src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/erd1.png" alt="Image" width="580" height="400"></kbd>

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
 
## Project Goal

<details> 
<summary>
Project Goal 
	
</summary>
<br>
	
Cindy Sharp, the Maven Fuzzy Factory CEO just sent you an email. She needs your help to prepare a presentation for the board meeting.

<p align="center">
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

</details> 

***

## Insight and Visualization

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

<p align="center">
<kbd><img width="750" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/charts/question_1_chart_rev.png"></kbd>

Gsearch traffic shows steady growth of sessions and orders.

### ✒ Q2: Next, it would be great to see a similar trend for gsearch, but this time **splitting out nonbrand and brand campaigns separately**. I am wondering if brand is picking up at all. If so, this is a good story to tell.

```sql
SELECT
  EXTRACT(YEAR_MONTH FROM website_sessions.created_at) AS yearmonth,
  COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
  COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
  ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) * 100.0, 2) AS nonbrand_cvr,
  COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
  COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
  ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) * 100.0, 2) AS brand_cvr
FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE utm_source = 'gsearch'
  AND website_sessions.created_at < '2012-11-27'
GROUP BY 1;
```

<kbd><img width="500" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_2_rev.PNG"></kbd>

<p align="center">
<kbd><img width="550" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/charts/question_2_chart_rev.png"></kbd>

In the early days of brand campaign, the conversion rate is very high at 9.23%, though the number of sessions and orders are still considered low compared to nonbrand campaign. The brand sessions and orders do increase steadily every month, and while still lower than nonbrand, in November its conversion rate still shows higher number than nonbrand (4.44% vs 4.19% for brand and nonbrand, respectively).

### ✒ Q3: While we're on gsearch, could you dive into nonbrand, and pull **monthly sessions and orders split by device type**? I want to flex our analytical muscles a little and show the board we really know our traffic sources.

```sql
SELECT
  EXTRACT(YEAR_MONTH FROM website_sessions.created_at) AS yearmonth,
  COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
  COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
    ROUND(COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) / 
  COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) * 100.0, 2) AS desktop_cvr,
  COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
  COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders,
    ROUND(COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) / 
  COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) * 100.0, 2) AS mobile_cvr
FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand'
  AND website_sessions.created_at < '2012-11-27'
GROUP BY 1;
```

<kbd><img width="500" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_3.PNG"></kbd>

<p align="center">
<kbd><img width="980" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/charts/question_3_chart.png"></kbd>

Majority of traffic sources are coming from users on desktop. Both desktop and mobile shows increased conversion rate from March to November 2012. Investigate why there are less session and orders from users who access through mobile, look into the the mobile webpages user interface and experience. 

### ✒ Q4: I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from gsearch. Can you pull **monthly trends for gsearch, alongside monthly trends for each of our other channels?**

First, find the various utm sources and referers to see the traffic we're getting

```sql
SELECT DISTINCT
  utm_source,
  utm_campaign,
  http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27';
```

<kbd><img width="300" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_4_part1.PNG"></kbd>

- If utm_source and utm_campaign IS NULL and http_referer IS NOT NULL, it means the sessions come from organic search sessions
- If utm_source and utm_campaign IS NULL and http_referer IS NULL, it means the sessions come directly from the web / users directly type the website link 

```sql
SELECT
  EXTRACT(YEAR_MONTH FROM website_sessions.created_at) AS yearmonth,
  COUNT(website_sessions.website_session_id) AS sessions,
  COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
  COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
  COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
  COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_sessions
FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1;
```

<kbd><img width="600" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_4_part2.PNG"></kbd>

<p align="center">
<kbd><img width="600" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/charts/question_4_chart.png"></kbd>

Number of sessions keep growing every month. Large portion of sessions come from gsearch, starting at 99% at March though it starts to decreased and contribute to 70% of total sessions in November. Bsearch traffic starts to grow in August, contributing to 12% of total and reach its highest in November at 22% of total sessions.

### ✒ Q5: I'd like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull **session to order conversion rates, by month**?

```sql
SELECT
  EXTRACT(YEAR_MONTH FROM website_sessions.created_at) AS yearmonth,
  COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id)*100.0, 2) AS conversion_rate
FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1;
```
<kbd><img width="250" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_5.PNG"></kbd>

<p align="center">
<kbd><img width="450" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/charts/question_5_chart.png"></kbd>

### ✒ Q6: For the gsearch lander test, please **estimate the revenue that test earned us** (**Hint:** Look at the increase in CVR from the test (JUn 19 - Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)

```sql
SELECT
  MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';
```

<kbd><img width="75" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_6_part1.PNG"></kbd>

The first website pageview id for lander test page is 23504

```sql
SELECT
  website_pageviews.pageview_url AS landing_page,
  COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
  COUNT(DISTINCT orders.order_id) AS orders,
  ROUND(COUNT(DISTINCT orders.order_id)/
    COUNT(DISTINCT website_sessions.website_session_id) * 100.0,2) AS conversion_rate
FROM website_sessions
INNER JOIN website_pageviews
  ON website_sessions.website_session_id = website_pageviews.website_session_id
LEFT JOIN orders
  ON website_sessions.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 23504
  AND website_sessions.created_at < '2012-07-28'
  AND website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
  AND website_pageviews.pageview_url IN ('/home', '/lander-1')
GROUP BY website_pageviews.pageview_url;
```

<kbd><img width="270" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_6_part2.PNG"></kbd>

Homepage lander conversion rate's is 3.18%, while new test lander page's conversion rate is 4.06%. The conversion rate is increased by 0.88%.

To calculate estimate revenue generated by new test lander page, first we find the last time /home page appeared, then we count the total sessions since that.

```sql
SELECT
  MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions
  LEFT JOIN website_pageviews
  ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand'
  AND pageview_url = '/home' -- Home landing page
  AND website_sessions.created_at < '2012-11-27';
```

<kbd><img width="300" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_6_part3.PNG"></kbd>

- Max website_session_id for /home is 17145
- After this session, there are no more /home landing page, and all landing page has been replaced with /lander-1

```sql
SELECT
  COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE
  created_at < '2012-11-27'
  AND website_session_id >= 17145 -- last home session
  AND utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand';
```

<kbd><img width="120" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_6_part4.PNG"></kbd>

**Calculate Average Revenue:**
- Conversion rate difference: 0.88%
- Total of sessions using `/lander-1` = 22,973
- 22,973 x 0.88% = estimated at least 202 incremental orders since July 29 using `\lander-1` page for roughly 4 months
- 202/4 = 50 additional orders per month. Awesome!!

<p align="center">
<kbd><img width="880" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/charts/question_6_chart.png"></kbd>

### ✒ Q7: For the landing page test you analyzed previously, it would be great to shows a **full conversion funnel from each of the two pages to orders**. You can use the same time period you analyzed last time (Jun 19 - Jul 28)

```sql
SELECT
  MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- First test lander-1 pageviews is 23504

SELECT
  website_sessions.website_session_id,
  website_pageviews.pageview_url,
  website_pageviews.created_at AS pageview_created_at,
  CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
  CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1_page,
  CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
  CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
  CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
  CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
  CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
  CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
  LEFT JOIN website_pageviews
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
  website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
  AND website_pageview_id >= 23504
  AND website_pageviews.created_at < '2012-07-28'
  AND website_pageviews.pageview_url IN ('/home', '/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
ORDER BY
  website_sessions.website_session_id,
  website_pageviews.created_at
;

-- next we will put the previous query inside a subquery (similar to temporary tables)
-- we will group by website_session_id, and take the MAX() of each of the flags
-- this MAX() becomes a made it flag for that session, to show the session made it there

CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT
  website_session_id,
  MAX(homepage) AS saw_homepage,
  MAX(custom_lander) AS saw_custom_lander,
  MAX(product_page) AS product_made_it,
  MAX(mrfuzzy_page) AS mrfuzzy_made_it,
  MAX(cart_page) AS cart_made_it,
  MAX(shipping_page) AS shipping_made_it,
  MAX(billing_page) AS billing_made_it,
  MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
  website_sessions.website_session_id,
  website_pageviews.pageview_url,
  website_pageviews.created_at AS pageview_created_at,
  CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
  CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
  CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
  CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
  CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
  CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
  CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
  CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
  LEFT JOIN website_pageviews
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
  website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
  AND website_pageviews.created_at < '2012-07-28'
  AND website_pageviews.created_at > '2012-06-19'
ORDER BY
  website_sessions.website_session_id,
  website_pageviews.created_at
) AS pageview_level
GROUP BY 1;

SELECT *
FROM session_level_made_it_flags;

-- then this will produce the final output (part 1)

SELECT
  CASE
    WHEN saw_homepage = 1 THEN 'saw_homepage'
    WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
    ELSE 'uh oh... check logic'
    END AS segment,
  COUNT(DISTINCT website_session_id) AS sessions,
  COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
  COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
  COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
  COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
  COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
  COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM
  session_level_made_it_flags
GROUP BY 1;

-- then this is the final output part 2, click rates or conversion rates
-- click rates or conversion rates is percentage of click rate from certain page divided by total sessions

SELECT
  CASE
    WHEN saw_homepage = 1 THEN 'saw_homepage'
    WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
    ELSE 'uh oh... check logic'
    END AS segment,
  ROUND(COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS products_click_rt,
  ROUND(COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS mrfuzzy_click_rt,
  ROUND(COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS cart_click_rt,
  ROUND(COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS shipping_click_rt,
  ROUND(COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS billing_click_rt,
  ROUND(COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS thankyou_click_rt
FROM
  session_level_made_it_flags
GROUP BY 1;
```
- Output 1: Sessions Funnel

<kbd><img width="480" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_7_sessions.PNG"></kbd>

- Output 2: Click Rates Funnel

<kbd><img width="580" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_7.PNG"></kbd>

The custom lander page has better click through rates than the original homepage.

### ✒ Q8: I'd love for you to **quantify the impact of our billing test**, as well. Please analyze the lift generated from the test (Sep 10 - Nov 10), in terms of **revenue per billing page sessions**, and then pull the number of billing page sessions for the past month to understand monthly impact.

```sql
SELECT
  billing_version_seen,
  COUNT(DISTINCT website_session_id) AS sessions,
  ROUND(SUM(price_usd) / COUNT(DISTINCT website_session_id), 2) AS revenue_per_session
FROM
(
SELECT
  website_pageviews.website_session_id,
  website_pageviews.pageview_url AS billing_version_seen,
  orders.order_id,
  orders.price_usd
FROM website_pageviews
  LEFT JOIN orders
    ON website_pageviews.website_session_id = orders.website_session_id
WHERE
  website_pageviews.created_at BETWEEN '2012-09-10' and '2012-11-10'
  AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1;
```

<kbd><img width="280" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_8_part1.PNG"></kbd>

- `/billing` page generates 657 sessions, with average USD 22,83 revenue per session
- `/billing-2` page generates 654 sessions, with average USD 31,34 revenue per session
- **INCREASE: USD 8.51 per session**

```sql
SELECT
  COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-27' AND '2012-11-27'
  AND pageview_url IN ('/billing', '/billing-2');
```

<kbd><img width="160" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/query_results/question_8_part2.PNG"></kbd>

- `/billing` page USD 22,83 revenue per session and new `/billing-2` page generates USD 31,34 revenue per session. The lift is **USD 8.51 per session**.
- Over the past month there has been 1,193 sessions. The new page has has generated **USD 10,153 increase in revenue**. 
	
<p align="center">
<kbd><img width="880" alt="image" src="https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/charts/question_8_chart.png"></kbd>


***

## Insight and Recommendation

**Insight**:

1. The website performance has seen improvements over the course of the first 8 months. The conversion rate starts at 3.19% in March and reached 4.40% in November.
2. Most of our traffic comes from users who access from desktop, almost 3/4 of traffic comes from desktop, while the rest comes from mobile.
3. In March, 99% of our traffic comes from gsearch. From August to November, our traffic sources are more diverse; 70% of it comes from gsearch, 22% comes from bsearch, and 8% comes from direct and organic.
4. The new `/lander-1` test shows better conversion rate compared to original `/home` page. The conversion rose from 3.18% to 4.06%, adding an increase of 0.88%. The `/lander-1` page generated additional 50 orders per month and also shows better click rates funnel.
5. The new `/billing-2` test page also shows better result than the previous `/billing` page, which brought additional USD 8.51 revenue per session. For the past month, there has been 1,193 session total, and the new billing page brought a total of USD 10,153 increase in revenue.

**Recommendation**:

1. With most of our users coming from desktop, we can focus our campaign and budget to desktop users. Additionally, evalute the mobile webpage and find why the traffic is low, then create a better user interface and experience for mobile users.
2. For paid marketing campaigns, most of the sessions come from gsearch than bsearch. We can focus our budget and campaign to gsearch for higher sessions reach in the future.


***

Thanks for visiting my repository 😃🌟


