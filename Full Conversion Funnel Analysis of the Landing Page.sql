/*
The CEO of this company is preparing a presentation for the board meeting to give them a better
understanding of our growth story over our first 8 months, so for the landing page test we analyzed previously, 
it would be great to show a full conversion funnel from each of the two pages to orders.
 */

USE mavenfuzzyfactory;

/*
STEP 1: use a subquery "pageview_visit" to first create a session-level conversion funnel view by assigning 1 if a certain page
is visited and null if not, and then aggregate the data to assess funnel performance in the form of a temporary table
 */

DROP TEMPORARY TABLE IF EXISTS conversion_funnel_sessions;

CREATE TEMPORARY TABLE conversion_funnel_sessions
SELECT
    (CASE
    	WHEN home = 1 THEN 'saw_homepage'
    	WHEN lander1 = 1 THEN 'saw_lander-1'
    END) AS segment,
    COUNT(website_session_id) AS sessions,
    SUM(products) AS to_products,
    SUM(mrfuzzy) AS to_mrfuzzy,
    SUM(cart) AS to_cart,
    SUM(shipping) AS to_shipping,
    SUM(billing) AS to_billing,
    SUM(thankyou) AS to_thankyou
FROM
  (
   SELECT
       wp.website_session_id,
       COUNT(CASE WHEN pageview_url = '/home' THEN 1 ELSE NULL END) AS home,
       COUNT(CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE NULL END) AS lander1,
       COUNT(CASE WHEN pageview_url = '/products' THEN 1 ELSE NULL END) AS products,
       COUNT(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END) AS mrfuzzy,
       COUNT(CASE WHEN pageview_url = '/cart' THEN 1 ELSE NULL END) AS cart,
       COUNT(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE NULL END) AS shipping,
       COUNT(CASE WHEN pageview_url = '/billing' THEN 1 ELSE NULL END) AS billing,
       COUNT(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END) AS thankyou
   FROM website_pageviews wp
   JOIN website_sessions ws USING (website_session_id)
   WHERE ws.created_at BETWEEN '2012-06-19' AND '2012-07-28'
   AND ws.utm_source = 'gsearch'
   AND ws.utm_campaign = 'nonbrand'
   GROUP BY website_session_id
  ) AS pageview_visit
GROUP BY 1;

-- STEP 2: calculate the click rates based on the temporary table

SELECT
    segment,
    to_products/sessions AS lander_click_rt,
    to_mrfuzzy/to_products AS products_click_rt,
    to_cart/to_mrfuzzy AS mrfuzzy_click_rt,
    to_shipping/to_cart AS cart_click_rt,
    to_billing/to_shipping AS shipping_click_rt,
    to_thankyou/to_billing AS billing_click_rt
FROM conversion_funnel_sessions