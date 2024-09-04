/*
On March 20, 2015, our CEO Cindy was close to securing Maven Fuzzy Factory’s next round of funding, 
and she would like to tell a compelling story to investors. So I pulled the relevant data, and helped 
Cindy craft a story about a data-driven company that had been producing rapid growth.
*/

/*
1. I pulled overall session and order volume, trended by quarter for the life of the business to show our volume growth.
*/

USE mavenfuzzyfactory;

SELECT 
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o USING (website_session_id)
GROUP BY 1,2
ORDER BY 1,2;

-- We can see some pretty dramatic growth when you look at the 60 orders from the first quarter.
-- We're now about 100 times that many orders and similar large growth in session volumne.

/*
2. Next, I showed quarterly figures since we launched, for session-to-order conversion rate, revenue per order, 
and revenue per session to showcase all of our efficiency improvements. 
*/

SELECT 
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(o.order_id)/COUNT(ws.website_session_id) AS session_to_order_conv_rate, 
    SUM(o.price_usd)/COUNT(o.order_id) AS revenue_per_order, 
    SUM(o.price_usd)/COUNT(ws.website_session_id) AS revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o USING (website_session_id)
GROUP BY 1,2
ORDER BY 1,2;

-- We've gone from session to order conversion rates around 3% at the very beginning to up over 7% and 8% in the most current quarter.
-- The revenue per order was initially only a flat $49.99 back when the company only sold one product.
-- It is really optimizing and now getting that revenue per order up above $60 after starting to do some cross-sell.
-- The revenue per session, which initially was around $1.59, now has gotten all the way up to over $5 in the most recent quarter.

/*
3. I also pulled a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, 
organic search, and direct type-in to show how we’ve grown specific channels.
*/

SELECT 
	YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(CASE WHEN ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand_orders, 
    COUNT(CASE WHEN ws.utm_source = 'bsearch' AND ws.utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand_orders, 
    COUNT(CASE WHEN ws.utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_search_orders,
    COUNT(CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN o.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN o.order_id ELSE NULL END) AS direct_type_in_orders
FROM website_sessions ws
LEFT JOIN orders o USING (website_session_id)
GROUP BY 1,2
ORDER BY 1,2;

-- We just see tremendous growth in all of these channels.
-- What the potential investors would be particularly excited about is brand search, organic search, and direct type ins really picking up.
-- Back in Q2 of 2012, we had almost 300 Gsearch Nonbrand orders and only a total of 56 across these three channels above (ratio: roughly 6:1).
-- We've got about 3,000 Gsearch Nonbrand orders and 1,800 orders in Q1 2015 from these three channels (ratio less than 2:1).
-- In conclusion, the business has become much less dependent on these paid Gsearch Non-brand campaigns.
-- It is starting to build its own brand organic and direct type in traffic, which has better margin and takes you out of the dependency of this search engine.

/*
4. Next, I showed the overall session-to-order conversion rate trends for those same channels, by quarter.
*/

SELECT 
	YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(CASE WHEN ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)
		/COUNT(CASE WHEN ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt, 
    COUNT(CASE WHEN ws.utm_source = 'bsearch' AND ws.utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) 
		/COUNT(CASE WHEN ws.utm_source = 'bsearch' AND ws.utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt, 
    COUNT(CASE WHEN ws.utm_campaign = 'brand' THEN o.order_id ELSE NULL END) 
		/COUNT(CASE WHEN ws.utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_search_conv_rt,
    COUNT(CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN o.order_id ELSE NULL END) 
		/COUNT(CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_search_conv_rt,
    COUNT(CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN o.order_id ELSE NULL END) 
		/COUNT(CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions ws
LEFT JOIN orders o USING (website_session_id)
GROUP BY 1,2
ORDER BY 1,2;

-- The Gsearch Nonbrand conversion rate has come up from 3.2%, 2.8% to well over 8% in the most recent quarter, which is fantastic.
-- Similar story with Bsearch and all of our direct channels, which have seen substantial improvements from where they were initially to where they are now.
-- These efficiency improvements show that the company knows what they're doing and they're striving to improve the business all the time, making a nice steady growth.

/*
5. Because we had come a long way since the days of selling a single product, I also pulled monthly trending for revenue 
and margin by product, along with total sales and revenue.
*/

SELECT
	YEAR(created_at) AS yr, 
    MONTH(created_at) AS mo, 
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,  
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items 
GROUP BY 1,2
ORDER BY 1,2;

-- We see a big pop in November and December each year in terms of the revenue of Mrfuzzy.
-- Probably because most U.S. students would recognize the holiday season as being really good for online retail.
-- Similar story with the Lovebear product, and there is a major pop in February each year.
-- This probably makes sense to a lot of people as well because this bear was targeted to couples for giving to one another as a gift (we see a large spike in revenue around the Valentine's Day holiday).
-- With the Birthdaybear, we may see some similar trends with a spike at the end of the year, but since we don't have as much data to understand its seasonality, it's a little hard to tell.
-- Same thing with the Minibear. It looks like there's a little bit of a pop at the end of the year, but January, 2015 also looks very strong as well. Since we don't have as much data for this one, it's also a little hard to tell.

/*
6. Next, I pulled monthly sessions to the /products page, and showed how the % of those sessions 
clicking through another page had changed over time, along with a view of how conversion from 
/products to placing an order had improved to showcase the impact of introducing new products.
*/

-- STEP 1: Use a subquery to track each session's view path, and mark the relevant pageview_ids
-- STEP 2: Calculate the relevant sessions, click through rates, and conversion rates based on the subquery result, and aggregate by year and month. 
SELECT 
    YEAR(first_created_at) AS yr,
    MONTH(first_created_at) AS mo,
    COUNT(DISTINCT CASE WHEN products_pageview_id IS NOT NULL THEN website_session_id ELSE NULL END) AS products_page_sessions,
    COUNT(DISTINCT CASE WHEN max_pageview_id > products_pageview_id THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN products_pageview_id IS NOT NULL THEN website_session_id ELSE NULL END) AS click_through_rt,
    COUNT(DISTINCT CASE WHEN thankyou_pageview_id IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN products_pageview_id IS NOT NULL THEN website_session_id ELSE NULL END) AS conv_rt
FROM
  (
   SELECT 
       website_session_id,
       MIN(created_at) AS first_created_at,
       MIN(CASE WHEN pageview_url = '/products' THEN website_pageview_id ELSE NULL END) AS products_pageview_id,
       MIN(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN website_pageview_id ELSE NULL END) AS thankyou_pageview_id,
       MAX(website_pageview_id) AS max_pageview_id
   FROM website_pageviews
   GROUP BY 1
  ) AS products_page_tracker
GROUP BY 1,2

-- We can see the click through rate has gone up from around 71% at the beginning of the business to 85% in the most recent month.
-- Similarly, the rate of people seeing the product page and then converting to a full paying order has gone up from 6-8% to all the way up to around 14% in the most recent months.
-- All of these improvements that the business has made, adding additional products that may appeal better to other people, bringing in a product at a lower price point, has really impacted the percentage of people that are clicking through on the product page in a positive way.
-- Similarly, it's really impacted the conversion rate to an order from the product page.
-- In all, these changes have been very positive and are helping to contribute to the health of the business.

/*
7. Since we made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item),
I pulled sales data since then, and showed how well each product cross-sold from one another.
*/

-- STEP 1: Create a temporary table to identify all cross-sell items in that time period.

DROP TEMPORARY TABLE IF EXISTS cross_sell_items;

CREATE TEMPORARY TABLE cross_sell_items
SELECT 
    product_id,
    order_id
FROM order_items
WHERE is_primary_item = 0
AND created_at BETWEEN '2014-12-05' AND '2015-03-20';

-- STEP 2: Left join orders table with cross_sell_items table in that time period in a subquery to calculate the number of orders of each combination.
-- STEP 3: Calculate the total orders, the orders in which each primary product cross-sold from one another, and their cross-sell rates based on the subquery.

SELECT
    primary_product_id,
    SUM(sales_vol) AS total_orders,
    SUM(CASE WHEN cross_sell_item = 1 THEN sales_vol END) AS x_p1,
    SUM(CASE WHEN cross_sell_item = 1 THEN sales_vol END)/SUM(sales_vol) AS x_p1_rt,
    SUM(CASE WHEN cross_sell_item = 2 THEN sales_vol END) AS x_p2,
    SUM(CASE WHEN cross_sell_item = 2 THEN sales_vol END)/SUM(sales_vol) AS x_p2_rt,
    SUM(CASE WHEN cross_sell_item = 3 THEN sales_vol END) AS x_p3,
    SUM(CASE WHEN cross_sell_item = 3 THEN sales_vol END)/SUM(sales_vol) AS x_p3_rt,
    SUM(CASE WHEN cross_sell_item = 4 THEN sales_vol END) AS x_p4,
    SUM(CASE WHEN cross_sell_item = 4 THEN sales_vol END)/SUM(sales_vol) AS x_p4_rt
FROM
  (
   SELECT 
       o.primary_product_id,
       cs.product_id AS cross_sell_item,
       COUNT(DISTINCT o.order_id) AS sales_vol
   FROM orders o
   LEFT JOIN cross_sell_items cs on o.order_id = cs.order_id
   WHERE o.created_at BETWEEN '2014-12-05' AND '2015-03-20'
   GROUP BY 1,2
   ) AS cross_sell_vol
GROUP BY 1

-- Product 1 is still the heavy hitter, followed by product 2 and product 3, whereas product 4 is the least likely to be the primary product.
-- Product 4 cross sold pretty well to product 1, product 2, and product 3. That's perhaps because product 4 was at the lower price point, so it was more of a snackable add on purchase for these customers.
-- Product 3 cross sold pretty well for product 1. 
-- Above 20% of the orders for primary product 1, 2, and 3 end up purchasing product 4 as well. 
-- So it seems like adding product 4 at that lower price point was probably a good thing for the business and maybe a major contributor to the higher average order value.
