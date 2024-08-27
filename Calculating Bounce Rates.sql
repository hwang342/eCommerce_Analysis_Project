/*
According to the Website Manager, so far (06/14/2012) all of our traffic is landing on the homepage, 
so she wants to check how that landing page is performing.
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
GROUP BY landing_page