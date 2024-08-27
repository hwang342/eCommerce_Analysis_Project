/*
The company launched its second product back on January 6th, 2013. As a result, the CEO
would like to see some trended analysis, including monthly order volume, overall conversion 
rates, revenue per session, and a breakdown of sales by product, all for the time period 
since April 1, 2012.
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
GROUP BY 1,2

/*
The data result since 2013 onfirms that our conversion rate and revenue per
session are improving over time, which is great. But we need to do some other
analysis to understand if the growth since January is due to our new product 
launch or just a continuation of our overall business improvements.
*/