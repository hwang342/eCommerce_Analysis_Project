USE mavenfuzzyfactory;

SELECT
    (CASE
    	WHEN wp.pageview_url = '/billing' THEN '/billing'
    	WHEN wp.pageview_url = '/billing-2' THEN '/billing-2'
    END) AS 'billing_version_seen',
    COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)/COUNT(DISTINCT wp.website_session_id) AS billing_to_order_rt
FROM website_pageviews wp
LEFT JOIN orders o USING (website_session_id)
WHERE wp.created_at BETWEEN '2012-09-10' AND '2012-11-10'
AND wp.pageview_url IN ('/billing', '/billing-2')
GROUP BY 1