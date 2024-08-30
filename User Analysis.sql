/*
1. On Nov. 1st, 2014, the Marketing Team decided to spend a bit more to acquire customers who had repeat sessions.
So I pulled data on how many of our website new visitors came back for another session from the beginning of 2014 up 
until then.
*/

USE mavenfuzzyfactory;

-- STEP 1: Identify the relevant repeat sessions in a temporary table

DROP TEMPORARY TABLE IF EXISTS sessions_repeated;

CREATE TEMPORARY TABLE sessions_repeated
SELECT
    user_id,
    website_session_id
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01'
AND is_repeat_session = 1;

-- STEP 2: Identify the relevant new sessions
-- STEP 3: Use the user_id values from STEP 1 to match the website_session_id with users identified in STEP 2
-- STEP 4: Analyze the data at the user level (how many repeat sessions did each user have?) in a subquery
-- STEP 5: Aggregate the user-level analysis to generate the behavioral analysis

SELECT 
    repeat_sessions,
    COUNT(user_id) AS users
FROM
  (
   SELECT
       ws.user_id,
       COUNT(sr.website_session_id) AS repeat_sessions
   FROM website_sessions ws
   LEFT JOIN sessions_repeated sr USING (user_id)
   WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-11-01'
   AND ws.is_repeat_session = 0
   GROUP BY 1
   ) AS numb_of_rpt_sessions_by_user
GROUP BY 1
ORDER BY 1

-- It seems a fair number of our customers did come back to our site after the first session

/*
2. Based on the data result above, the Marketing Team would like to dive deeper into the minimum, maximum, and
average time between the first and second session for customers who did come back. So I pulled these data from
2014 to date (Nov. 3, 2014).
*/

-- STEP 1: Identify the relevant new sessions and their created_at times, which are also the first sessions and first_created_at times

DROP TEMPORARY TABLE IF EXISTS new_sessions;

CREATE TEMPORARY TABLE new_sessions
SELECT
    user_id,
    website_session_id AS first_session_id,
    created_at AS first_created_at
FROM website_sessions
WHERE is_repeat_session = 0
AND created_at BETWEEN '2014-01-01' AND '2014-11-03';

-- STEP 2: Use the user_id values from STEP 1 to find their corresponding second sessions and second_created_at times by an inner join in a subquery
-- STEP 3: Find the differences between first and second sessions at a user level
-- STEP 4: Aggregate the user level data to find the average, min, max

SELECT
    AVG(DATEDIFF(second_created_at, first_created_at)) AS avg_days_first_to_second,
    MIN(DATEDIFF(second_created_at, first_created_at)) AS min_days_first_to_second,
    MAX(DATEDIFF(second_created_at, first_created_at)) AS max__days_first_to_second
FROM
  (
   SELECT 
       ns.user_id,
       ns.first_session_id,
       ns.first_created_at,
       MIN(ws.website_session_id) AS second_session_id,
       MIN(ws.created_at) AS second_created_at
   FROM new_sessions ns
   JOIN website_sessions ws USING (user_id)
   WHERE ws.is_repeat_session = 1
   AND ws.created_at BETWEEN '2014-01-01' AND '2014-11-03'
   GROUP BY 1,2,3
   ) AS repeat_sessions

-- The result shows that these repeat visitors were coming back about a month later, on average
   
/*
3. The Marketing Team also wanted to understand the channels they came back through. They were curious if it
was all direct type-in, or if we were paying for these customers with paid search ads multiple times. Therefore,
I compared new vs. repeat sessions by channel.
*/

-- STEP 1: Identify filter conditions for different types channel group
-- STEP 2: Count the number of new sessions and repeat sessions in the given time period
-- STEP 3: Aggregate the data by channel_group

SELECT 
    (CASE 
     	WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic_search'
     	WHEN utm_campaign = 'brand' THEN 'paid_brand'
     	WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
     	WHEN utm_source IS NOT NULL AND utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
     	WHEN utm_source = 'socialbook' THEN 'paid_social'
     END) AS channel_group,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1
ORDER BY 3 DESC

-- The result shows that when customers came back for repeat visits, they came mainly through organic search, direct type-in, and paid brand.
-- Only about 1/3 came through a paid channel, and brand clicks are cheaper than nonbrand.
-- All in all, we were not paying very much for these subsequent visits.

/*
4. Based on the results above, both the Marketing Team and Website Team wondered whether these repeat sessions converted to orders. Therefore,
I did a comparison of conversion rates and revenue per session for repeat sessions vs new sessions.
*/

-- STEP 1: Left join the website_sessions table with the orders table
-- STEP 2: Calculate the number of sessions, conv_rate, and rev_per_session and aggregate these data by is_repeat_session

SELECT 
    ws.is_repeat_session,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id)/COUNT(ws.website_session_id) AS conv_rate,
    SUM(o.price_usd)/COUNT(ws.website_session_id)AS rev_per_session
FROM website_sessions ws
LEFT JOIN orders o USING (website_session_id)
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1

-- Looks like repeat sessions were more likely to convert, and produced more revenue per session.