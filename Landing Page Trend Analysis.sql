/*
The Website Manager wanted to confirm the traffic was all routed correctly,
and make sure the lander change has improved the overall picture. So she asked
me to pull the volume of paid search nonbrand traffic landing on /home and 
/lander-1, trended weekly since June 1st, as well as our overall paid search 
bounce rate trended weekly.
(This request was sent on August 31, 2012.)
 */

USE mavenfuzzyfactory;

-- STEP 1: finding the first website_pageview_id for relevant sessions

DROP TEMPORARY TABLE IF EXISTS first_pageview;

CREATE TEMPORARY TABLE first_pageview
SELECT
    website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2012-06-01' AND '2012-08-31'
GROUP BY website_session_id;

-- STEP 2: counting pageviews for each session, to identify "bounces"

DROP TEMPORARY TABLE IF EXISTS count_pageview_id;

CREATE TEMPORARY TABLE count_pageview_id
SELECT
    website_session_id,
    COUNT(website_pageview_id) AS number_of_pages_viewed
FROM website_pageviews
WHERE created_at BETWEEN '2012-06-01' AND '2012-08-31'
GROUP BY website_session_id;

-- STEP 3: summarizing by week (bounce rate, sessions for each lander)

SELECT
   DATE(MIN(ws.created_at)) AS week_start_date,
   COUNT(CASE WHEN cp.number_of_pages_viewed = 1 THEN 1 ELSE NULL END)/COUNT(ws.website_session_id) AS bounce_rate,
   COUNT(CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE NULL END) AS home_sessions,
   COUNT(CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE NULL END) AS lander_sessions
FROM website_sessions ws
JOIN count_pageview_id cp ON ws.website_session_id = cp.website_session_id
JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id
JOIN first_pageview fp ON wp.website_pageview_id = fp.min_pageview_id
WHERE ws.created_at BETWEEN '2012-06-01' AND '2012-08-31' AND ws.utm_campaign = 'nonbrand' AND ws.utm_source = 'gsearch'
GROUP BY WEEK(ws.created_at)