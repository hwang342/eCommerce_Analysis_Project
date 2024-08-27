/*
As a follow up of the company's 2nd product (the forever love bear) launch (Jan. 6, 2013), the Website Manager requested
to look at the conversion funnels for each product individually to see if the new product was generating 
additional product interest overall.
(This request was sent on April 10, 2013)
 */

USE mavenfuzzyfactory;

/*
STEP 1: create a temporary table "view_path" to record a session-level view path by assigning 1 if a certain page
is viewed and null if not
 */

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

/*
STEP 2: First use a subquery "pageview_session" to aggregate the session-level data from the temporary table "view_path"
by the product page, and then calculate these click rates.
 */

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