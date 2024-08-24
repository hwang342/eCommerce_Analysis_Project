# Maven Fuzzy Factory eCommerce Analytics
## Introduction
Maven Fuzzy Factory is a fictional toy company, running an online shop. This project aimed to help stakeholders, including the CEO, the Head of Marketing, and the
Website Manager, understand business health and provide actionable recommendations to steer the business.
## Objectives
* Analyze and optimize marketing channels, measure and test website conversion performance for improving bid strategy
* Use data to understand the impact of new product launches
* Analyze most-viewed pages and landing page performance, and use conversion funnel analysis to understand how many users continue/abandon at each step
* Analyze seasonality and business patterns to help the company maximize efficiency and anticipate future trends
* Analyze customer behavior to understand which products users are most likely to purchase together for better cross-selling and upselling
## ER Diagram of the Database
![erd](https://github.com/hwang342/eCommerce_Analysis_Project/blob/main/ERD.png?raw=true)
## Database Description
* website_sessions table
  * utm parameters(utm_source/utm_campaign/utm_content) are associated with paid traffic
* website_pageviews table
* products table
* orders table
  * primary_product_id column: each order has a primary product
* order_items table
  * is_primary_item BINARY column: if an item is the primary item, then it's 1, if an item is cross-selling item added in cart page, then it's 0
* order_item_refunds table
