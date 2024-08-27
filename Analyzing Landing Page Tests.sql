/*
According to the Website Manager, they ran a new custom landing page (/lander-1) 
in a 50/50 test against the homepage (/home) for our gsearch nonbrand traffic.
She asked me to pull bounce rates for the two groups so we could evaluate the new page.
(This request was sent on July 28, 2012.)
 */

USE mavenfuzzyfactory;

/*
STEP 1: counting pageviews for each session, to identify "bounces", after finding out 
when the new page /lander-1 launched (2012-06-19 00:35:54). We must just look at the time
period where /lander-1 was getting traffic, so that it is a fair comparison.
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
GROUP BY landing_page