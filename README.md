# Startup Growth Analytics: SaaS Subscription & Churn Analysis

## Overview

This project analyzes customer growth, subscription revenue, product usage, support activity, and churn for a fictional SaaS company called RavenStack. The goal is to understand what drives customer retention, identify the main reasons customers leave, and uncover opportunities for business growth.

The project combines SQL, Python, and Power BI to demonstrate a complete analytics workflow, from data cleaning and exploration to business insights and dashboard development.

## Business Scenario

RavenStack is a subscription-based software company preparing for a larger market launch. Although customer acquisition has been growing steadily, the company is experiencing a relatively high churn rate and wants to understand the factors affecting customer retention.

Key business questions include:

* Why are customers churning?
* Which customer segments are most likely to stay?
* How is recurring revenue changing over time?
* Which product features are driving engagement?
* Does customer support quality influence retention?

The analysis focuses on answering these questions using customer, subscription, product usage, support, and churn data.

## Dataset

The project uses a synthetic SaaS dataset consisting of five related tables:

| Table           | Description                                             |
| --------------- | ------------------------------------------------------- |
| accounts        | Customer profile and signup information                 |
| subscriptions   | Subscription history, billing, upgrades, and downgrades |
| feature_usage   | Product feature engagement records                      |
| support_tickets | Customer support interactions and satisfaction scores   |
| churn_events    | Customer churn records and churn reasons                |

All data used in this project is synthetic and created for analytics practice purposes.

## Project Structure

startup_growth_analysis/

├── data/

│ ├── raw/

│ └── processed/

├── sql/

│ ├── schema.sql

│ ├── data_load.sql

│ ├── revenue_analysis.sql

│ ├── churn_analysis.sql

│ ├── cohort_analysis.sql

│ ├── feature_adoption.sql

│ └── support_analysis.sql

├── notebooks/

│ ├── 01_eda.ipynb

│ ├── 02_cohort_analysis.ipynb

│ ├── 03_churn_analysis.ipynb

│ └── 04_business_insights.ipynb

├── dashboard/

├── visuals/

├── reports/

├── requirements.txt

└── README.md

## Tools Used

* PostgreSQL
* Python
* Pandas
* NumPy
* Matplotlib
* Power BI

## Analysis Performed

### SQL Analysis

The SQL portion focuses on:

* Revenue and MRR analysis
* Customer churn analysis
* Cohort retention analysis
* Feature adoption analysis
* Support performance analysis

Common SQL techniques include joins, CTEs, window functions, aggregations, and ranking functions.

### Python Analysis

Python was used for:

* Data cleaning and validation
* Exploratory data analysis
* Cohort retention calculations
* Churn analysis
* Business insight generation
* Data visualization

Visualizations were created using Matplotlib and exported for reporting and dashboard development.

### Power BI Dashboard

The dashboard includes:

* Executive KPI overview
* Revenue performance
* Retention and churn tracking
* Product usage metrics
* Customer support metrics

The dashboard is designed to provide stakeholders with a clear view of customer growth, engagement, and revenue performance.

## Key Insights

Some of the major findings from the analysis include:

* Pricing-related issues were the most common reason for customer churn.
* Customer retention drops most significantly during the first few months after signup.
* Organic and partner-acquired customers showed stronger retention than paid channels.
* Customers with higher support ticket volumes were more likely to churn.
* Enterprise customers had the lowest churn rates.
* A small number of features generated most of the overall product engagement.

## Recommendations

Based on the findings, the following actions are recommended:

1. Introduce additional pricing options for growing customers.
2. Improve onboarding during the first 30–60 days.
3. Build an early warning system for churn risk.
4. Invest more in high-performing acquisition channels.
5. Address product areas with high error rates.
6. Improve response times for urgent support requests.
7. Develop a structured win-back strategy for churned customers.

## How to Run the Project

### Python

Install dependencies:

pip install -r requirements.txt

Run the notebooks in the following order:

1. 01_eda.ipynb
2. 02_cohort_analysis.ipynb
3. 03_churn_analysis.ipynb
4. 04_business_insights.ipynb

### PostgreSQL

1. Create a database.
2. Run schema.sql.
3. Load the CSV files.
4. Execute the analysis scripts in the sql folder.

## Future Enhancements

Potential improvements include:

* Customer health scoring
* Automated reporting workflows
* Dashboard migration to additional BI tools
* Automated data refresh pipelines
* Feature-level retention analysis
* Geographic performance analysis

## Conclusion

This project demonstrates a complete analytics workflow using SQL, Python, and Power BI. It focuses on solving common SaaS business problems related to growth, retention, customer engagement, and revenue performance while presenting findings in a business-friendly format.
