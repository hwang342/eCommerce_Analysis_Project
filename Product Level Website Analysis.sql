/*
1. The company launched its second product back on January 6th, 2013. As a result, on April 5th, the CEO
requested to see some trended analysis, including monthly order volume, overall conversion rates, 
revenue per session, and a breakdown of sales by product, all for the time period since April 1, 2012.
*/

USE mavenfuzzyfactory;

SELECT 
    YEAR(o.created_at) AS yr,
    MONTH(o.created_at) AS mo,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)/COUNT(ws.website_session_id) AS conv_rate,
    SUM(o.price_usd)/COUNT(ws.website_session_id) AS rev_per_session,
    COUNT(CASE WHEN o.primary_product_id = 1 THEN o.order_id ELSE NULL END) AS product_one_orders,
    COUNT(CASE WHEN o.primary_product_id = 2 THEN o.order_id ELSE NULL END)AS product_two_orders
FROM website_sessions ws
LEFT JOIN orders o USING (website_session_id)
WHERE ws.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1,2;

-- The data result shows that our conversion rate and revenue per session have improved over time. 
-- More analysis needed to understand if the growth since January is due to our new product launch or just a continuation of our overall business improvements.

/*
2. Now that we have a new product, we need to analyze our user path and conversion funnel. So I looked at 
sessions which hit the /products page, found where they went next, pulled clickthrough rates from 
/products since the new product launch on January 6th, by product, and compared to the 3 months leading up to 
launch as a baseline.
*/

-- STEP 1: create a temporary table to find the website sessions that viewed /the-original-mr-fuzzy or /the-forever-love-bear page
-- (The logic of this website is a user can only view a specific product page after viewing the /products page)

DROP TEMPORARY TABLE IF EXISTS next_pg;

CREATE TEMPORARY TABLE next_pg
SELECT
    website_session_id,
    pageview_url
FROM website_pageviews
WHERE pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear');

-- STEP 2: left join the temporary table with website_pageviews table using website_session_id
-- STEP 3: calculate the number of relevant sessions and clickthrough rates, and analyze the pre vs. post periods

SELECT
    (CASE
	    WHEN created_at BETWEEN '2012-10-06' AND '2013-01-06' THEN 'A.Pre_Product_2'
	    WHEN created_at BETWEEN '2013-01-06' AND '2013-04-06' THEN 'B.Post_Product_2'
	END) AS time_period,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/products' THEN wp.website_session_id ELSE NULL END) AS sessions,
    COUNT(DISTINCT np.website_session_id) AS w_next_pg,
    COUNT(DISTINCT np.website_session_id)/COUNT(DISTINCT CASE WHEN wp.pageview_url = '/products' THEN wp.website_session_id ELSE NULL END) AS pct_w_next_pg,
    COUNT(DISTINCT CASE WHEN np.pageview_url = '/the-original-mr-fuzzy' THEN np.website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN np.pageview_url = '/the-original-mr-fuzzy' THEN np.website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN wp.pageview_url = '/products' THEN wp.website_session_id ELSE NULL END) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN np.pageview_url = '/the-forever-love-bear' THEN np.website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN np.pageview_url = '/the-forever-love-bear' THEN np.website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN wp.pageview_url = '/products' THEN wp.website_session_id ELSE NULL END) AS pct_to_lovebear
FROM website_pageviews wp
LEFT JOIN next_pg np USING (website_session_id)
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
GROUP BY time_period;

-- The percent of /products pageviews that clicked to Mr. Fuzzy has gone down since the launch of the Love Bear.
-- But the overall clickthrough rate has gone up, so it seems to be generating additional product interest overall.

/*
3. Four days later, as a follow up, the Website Team would like to look at the conversion funnels for each product individually.
*/

-- STEP 1: create a temporary table "view_path" to record a session-level view path by assigning 1 if a certain page is viewed and null if not

DROP TEMPORARY TABLE IF EXISTS view_path;

CREATE TEMPORARY TABLE view_path
SELECT
    website_session_id,
    COUNT(CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE NULL END) AS lovebear_viewed,
    COUNT(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END) AS mrfuzzy_viewed,
    COUNT(CASE WHEN pageview_url = '/cart' THEN 1 ELSE NULL END) AS cart_viewed,
    COUNT(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE NULL END) AS shipping_viewed,
    COUNT(CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE NULL END) AS billing_viewed,
    COUNT(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END) AS order_placed
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
GROUP BY website_session_id;

-- STEP 2: aggregate the session-level data from the temporary table "view_path" by specific product page viewed
-- STEP 3: calculate click rates from the subquery "pageview_sessions", which contains the result of STEP 2

SELECT 
    product_seen,
    to_cart/sessions AS product_page_click_rt,
    to_shipping/to_cart AS cart_click_rt,
    to_billing/to_shipping AS shipping_click_rt,
    to_thankyou/to_billing AS billing_click_rt
FROM
  (
   SELECT 
     (CASE
	     WHEN lovebear_viewed = 1 THEN 'lovebear'
    	 WHEN mrfuzzy_viewed = 1 THEN 'mrfuzzy'
     END) AS product_seen,
     COUNT(DISTINCT website_session_id) AS sessions,
     COUNT(DISTINCT CASE WHEN cart_viewed = 1 THEN website_session_id ELSE NULL END) AS to_cart,
     COUNT(DISTINCT CASE WHEN shipping_viewed = 1 THEN website_session_id ELSE NULL END)AS to_shipping,
     COUNT(DISTINCT CASE WHEN billing_viewed = 1 THEN website_session_id ELSE NULL END)AS to_billing,
     COUNT(DISTINCT CASE WHEN order_placed = 1 THEN website_session_id ELSE NULL END)AS to_thankyou
   FROM view_path
   GROUP BY product_seen
   ) AS pageview_sessions
WHERE product_seen IN ('lovebear', 'mrfuzzy')