/*
1. According to the Website Manager, up untill June 14, 2012, all of our traffic was landing on the homepage, 
so I pulled bounce rates for traffic landing on homepage to see how it was performing.
*/

USE mavenfuzzyfactory;

-- STEP 1: finding the first website_pageview_id for relevant sessions

DROP TEMPORARY TABLE IF EXISTS first_pageview;

CREATE TEMPORARY TABLE first_pageview
SELECT
    website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

-- STEP 2: counting pageviews for each session, to identify "bounces"

DROP TEMPORARY TABLE IF EXISTS count_pageview_id;

CREATE TEMPORARY TABLE count_pageview_id
SELECT
    website_session_id,
    COUNT(website_pageview_id) AS number_of_pages_viewed
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

-- STEP 3: summarizing by counting total sessions and bounced sessions

SELECT
    wp.pageview_url AS landing_page,
    COUNT(DISTINCT fp.website_session_id) AS number_of_sessions,
    COUNT(CASE WHEN cp.number_of_pages_viewed = 1 THEN 1 ELSE NULL END) AS bounced_sessions,
    COUNT(CASE WHEN cp.number_of_pages_viewed = 1 THEN 1 ELSE NULL END)/COUNT(DISTINCT fp.website_session_id) AS bounce_rate
FROM website_pageviews wp
JOIN first_pageview fp ON wp.website_pageview_id = fp.min_pageview_id
JOIN count_pageview_id cp ON cp.website_session_id = wp.website_session_id
GROUP BY landing_page;

-- The bounce rate was almost 60%, which was pretty high, especially for paid search, which should be high quality traffic. 
-- Therefore, the Website Manager decided to put together a custom landing page for search, and set up an A/B test.

/*
2. Based on my bounce rate analysis, the Website Manager's team ran a new custom landing page (/lander-1) in a 50/50 test 
against the homepage (/home) for our gsearch nonbrand traffic. So I pulled bounce rates for the two groups so we could 
evaluate the new page when we got enough data to judge performance on July 28.
*/

/*
STEP 1: counting pageviews for each session, to identify "bounces", after finding out when the new page /lander-1 
launched (2012-06-19 00:35:54). We must just look at the time period where /lander-1 was getting traffic, so that 
it is a fair comparison.
*/

DROP TEMPORARY TABLE IF EXISTS count_pageview_id;

CREATE TEMPORARY TABLE count_pageview_id
SELECT
    website_session_id,
    COUNT(website_pageview_id) AS number_of_pages_viewed
FROM website_pageviews
WHERE created_at BETWEEN '2012-06-19 00:35:54' AND '2012-07-28'
GROUP BY website_session_id;

-- STEP 2: finding the first website_pageview_id for relevant sessions

DROP TEMPORARY TABLE IF EXISTS first_pageview;

CREATE TEMPORARY TABLE first_pageview
SELECT
    website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2012-06-19 00:35:54' AND '2012-07-28'
GROUP BY website_session_id;

-- STEP 3: summarizing total sessions and bounced sessions, by landing page.

SELECT
    wp.pageview_url AS landing_page,
    COUNT(DISTINCT fp.website_session_id) AS total_sessions,
    COUNT(CASE WHEN cp.number_of_pages_viewed = 1 THEN 1 ELSE NULL END) AS bounced_sessions,
    COUNT(CASE WHEN cp.number_of_pages_viewed = 1 THEN 1 ELSE NULL END)/COUNT(DISTINCT fp.website_session_id) AS bounce_rate
FROM website_pageviews wp
JOIN first_pageview fp ON wp.website_pageview_id = fp.min_pageview_id
JOIN count_pageview_id cp ON cp.website_session_id = wp.website_session_id
JOIN website_sessions ws ON wp.website_session_id = ws.website_session_id
WHERE
   ws.utm_source = 'gsearch'
   AND ws.utm_campaign = 'nonbrand'
GROUP BY landing_page;

-- It looks like the custom lander has a lower bounce rate...success!
-- As a result, the Marketing Team decided to get campaigns updated so that all nonbrand paid traffic was pointing to the new page.

/*
3. The Website Manager wanted to confirm the traffic was all routed correctly, and make sure the lander change has 
improved the overall picture. So on August 31, 2012, she asked me to pull the volume of paid search nonbrand traffic 
landing on /home and /lander-1, trended weekly since June 1st, as well as our overall paid search bounce rate trended weekly.
*/

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
GROUP BY WEEK(ws.created_at);

-- Looks like both pages were getting traffic for a while, and then we fully switched over to the custom lander, as intended.
-- Looks like our overall bounce rate came down over time, which was great.
