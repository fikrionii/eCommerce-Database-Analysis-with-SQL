-- eCommerce Database Analysis
-- Alfikri Ramadhan
-- December 2022

USE mavenfuzzyfactory;

/*
-- TASK 1
Gsearch seem to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders
so that we can showcase the growth there?
*/

SELECT
	EXTRACT(YEAR_MONTH FROM website_sessions.created_at) AS yearmonth,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) * 100.0, 2) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE utm_source = 'gsearch'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 1;

/*
-- TASK 2
Next, it would be great to see a similar monthly trend for gsearch, but this time splitting non brand and brand campaigns separately.
I am wondering if brand is picking up at all. If so, this is a good story to tell.
*/

SELECT
	DISTINCT utm_campaign,
    utm_content
FROM
	website_sessions
WHERE website_sessions.created_at < '2012-11-27';

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

/*
-- TASK 3
While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our
analytical muscles a little and show the board we really know our traffic sources
*/

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

/*
-- TASK 4
I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch.
Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/

-- First, find the various utm sources and referers to see the traffic we're getting

SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27';

/*
When utm_source and utm_campaign IS NULL and http_referer IS NOT NULL, it means the sessions come from organic search sessions,
when utm_source and utm_campaign IS NULL and http_referer IS NULL, it means the sessions come direct to the web
*/

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

/*
-- TASK 5
I'd like to tell the story of our website performance improvemnets over the course of the first 8 months.
Could you pull session to order conversion rates, by month?
*/

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

/*
-- TASK 6
For the gsearch lander test, please estimate the revenue that test earned us (Hint: look at the increase in CVR from
the test (Jun 19 - Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
*/

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

SELECT
	MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- First test lander-1 pageviews is 23504

CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
	MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
	JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_pageview_id >= 23504
		AND website_pageviews.created_at < '2012-07-28'
		AND utm_source = 'gsearch'
		AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

-- 0.0318 for /home, vs 0.0406 for /lander-1
-- additional 0.0088 orders per session

-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to home

SELECT
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home' -- Home landing page
    AND website_sessions.created_at < '2012-11-27';

-- max website_session_id = 17145
-- After this session, there are no more /home landing page, and all landing page has been replaced with /lander-1

SELECT
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE
	created_at < '2012-11-27'
    AND website_session_id >= 17145 -- last home session
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';
    
-- 22973 sessions since test

-- X 0.0088 incremental conversion = 202 incremental orders since 29 July
	-- roughly 4 months, so roughly 50 extra orders per month, awesome!

/*
-- TASK 7
For the landing page you analyzed previously, it would be great to show a full conversion funnel from each
of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 - Jul 28)
*/

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

/*
-- TASK 8
I'd love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test
(Sep 10 - Nov 10), in terms of revenue per billing page session, then pull the number of billing page sessions for the
past month to understand monthly impact.
*/

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
    
-- /billing page generates 657 sessions, with USD 22,83 revenue per session
-- /billing-2 page generates 654 sessions, with USD 31,34 revenue per session
-- INCREASE: USD 8.51 per session

SELECT
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-27' AND '2012-11-27'
	AND pageview_url IN ('/billing', '/billing-2');
    
-- 1193 billing sessions past month
-- LIFT: USD 8.51 per billing session
-- VALUE OF BILLING TEST: USD 10,153 over the past month