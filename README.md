# Startup Growth Analytics: SaaS Subscription & Churn Analysis

<div align="center">

![Project Banner](visuals/00_executive_dashboard.png)

**A complete end-to-end Data Analytics project on a synthetic SaaS company — built to showcase SQL, Python, and Power BI skills at a professional level.**

[![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white)](https://python.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)](https://postgresql.org)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)](https://powerbi.microsoft.com)
[![License](https://img.shields.io/badge/Dataset%20License-MIT--like-green)](https://rivalytics.medium.com)

</div>

---

## Table of Contents
- [Project Overview](#project-overview)
- [Business Problem](#business-problem)
- [Dataset Description](#dataset-description)
- [Project Architecture](#project-architecture)
- [SQL Analysis Summary](#sql-analysis-summary)
- [Python Analysis Summary](#python-analysis-summary)
- [Power BI Dashboard](#power-bi-dashboard)
- [Key Findings](#key-findings)
- [Business Recommendations](#business-recommendations)
- [Getting Started](#getting-started)
- [Future Improvements](#future-improvements)
- [Credits](#credits)

---

## Project Overview

This project simulates the analytics workflow of a Data Analyst at **RavenStack**, a stealth-mode B2B SaaS startup delivering AI-driven team productivity tools. The company piloted its product with coding bootcamp graduates and captured every sign-up, subscription event, feature interaction, support ticket, and churn event.

The goal is to translate this raw operational data into actionable business intelligence — answering the questions leadership needs answered before a public product launch.

**Scope:**
- 500 customer accounts across 5 industries and 10+ countries
- 5,000 subscription records covering plan changes, upgrades, and downgrades
- 25,000 feature usage events across 40 product features
- 2,000 customer support tickets
- 600 churn events with reason codes and feedback

---

## Business Problem

RavenStack is preparing for its public launch, but pilot data reveals a **gross churn rate of ~24%** — significantly above the healthy SaaS benchmark of 5–10% annually. Leadership needs to understand:

1. **Why are customers leaving?** What are the primary churn drivers?
2. **Which customers stay?** What do high-retention cohorts have in common?
3. **Is the revenue healthy?** How is MRR trending, and where is growth coming from?
4. **Is the product being used?** Which features drive engagement and which are abandoned?
5. **Is support a churn risk?** Does poor support experience predict customer exits?

This project answers all five questions with data.

---

## Dataset Description

> **Dataset:** RavenStack Synthetic SaaS Dataset  
> **Author:** River @ Rivalytics  
> **License:** MIT-like (fully synthetic, no PII) — credit required  
> **Source:** [rivalytics.medium.com](https://rivalytics.medium.com)

| Table | Rows | Description |
|---|---|---|
| `accounts.csv` | 500 | One row per customer company. Contains signup date, plan tier, industry, country, referral source. |
| `subscriptions.csv` | 5,000 | One row per billing period. Contains MRR, ARR, plan changes, upgrade/downgrade flags. |
| `feature_usage.csv` | 25,000 | Feature-level usage events with duration, usage count, and error counts. |
| `support_tickets.csv` | 2,000 | Support tickets with priority, resolution time, CSAT score, and escalation flag. |
| `churn_events.csv` | 600 | Churn events with reason codes, refund amounts, and reactivation flags. |

### Entity Relationship Diagram

```
accounts (PK: account_id)
│
├── subscriptions   (FK: account_id)
│   └── feature_usage  (FK: subscription_id)
│
├── support_tickets (FK: account_id)
└── churn_events    (FK: account_id)
```

---

## Project Architecture

```
startup_growth_analysis/
│
├── data/
│   ├── raw/                        ← Original CSV files (5 tables)
│   └── processed/                  ← Cleaned & enriched CSVs from Python
│
├── sql/
│   ├── schema.sql                  ← Table definitions + indexes
│   ├── data_load.sql               ← COPY commands + integrity checks
│   ├── revenue_analysis.sql        ← MRR, ARR, waterfall, growth rate
│   ├── churn_analysis.sql          ← Monthly churn, reasons, signals
│   ├── cohort_analysis.sql         ← Retention matrices, NRR
│   ├── feature_adoption.sql        ← Adoption breadth, error rates
│   └── support_analysis.sql        ← CSAT, SLA, escalations
│
├── notebooks/
│   ├── 01_eda.ipynb                ← Data quality + exploratory analysis
│   ├── 02_cohort_analysis.ipynb    ← Retention heatmaps + NRR curves
│   ├── 03_churn_analysis.ipynb     ← Churn trends, reasons, signals
│   └── 04_business_insights.ipynb  ← Revenue, features, executive summary
│
├── reports/
│   ├── executive_summary.md        ← Full analytical narrative
│   └── business_recommendations.md ← 7 data-driven action items
│
├── dashboard/
│   └── Startup_Growth_Analytics_Dashboard_Guide.md  ← Power BI build guide
│
├── visuals/                        ← PNG charts exported from notebooks
│
├── README.md
├── requirements.txt
└── .gitignore
```

---

## SQL Analysis Summary

All SQL is written for **PostgreSQL 14+** using best practices: CTEs, window functions, lateral joins, and analytical aggregations.

| File | Key Analyses |
|---|---|
| `schema.sql` | 5 tables, 11 indexes, full column comments |
| `data_load.sql` | COPY commands (server + client-side), post-load row count verification, 4 referential integrity checks |
| `revenue_analysis.sql` | Monthly MRR snapshot with active subscription spine, MRR by plan tier, MRR waterfall (new/expansion/contraction/churned), revenue by industry and country, LTV ranking, billing frequency split, MoM growth rate with `LAG()`, ARR snapshot |
| `churn_analysis.sql` | Overall churn summary, monthly churn rate with `SUM() OVER()`, churn by reason with LATERAL join for MRR lost, churn by plan/industry, pre-churn downgrade signal, time-to-churn with `PERCENTILE_CONT`, MRR churn rate, reactivation analysis |
| `cohort_analysis.sql` | Cohort view definition, account-based retention matrix, retention by referral source, revenue cohort NRR, 6-month pivot summary, average retention by period |
| `feature_adoption.sql` | Full adoption summary, adoption rate vs. active subscriptions, monthly usage trends, top-10 by plan tier with `ROW_NUMBER()`, beta vs. GA comparison, error rate ranking, adoption by referral source, power user identification with `PERCENTILE_CONT`, DAU proxy |
| `support_analysis.sql` | Overall KPIs with `PERCENTILE_CONT`, monthly load, performance by priority, CSAT distribution, CSAT trend with promoter/detractor split, high-load accounts, churn correlation, escalation by plan/priority, SLA compliance, heatmap by hour/day |

---

## Python Analysis Summary

All notebooks use **Pandas, NumPy, and Matplotlib** only — no ML libraries. Dark-themed, publication-quality visuals are saved to `visuals/`.

### 01_eda.ipynb — Exploratory Data Analysis
- Loads and validates all 5 datasets (dtypes, nulls, duplicates)
- Referential integrity checks (orphan row detection)
- Date logic validation (subscription start ≥ signup date)
- Descriptive statistics for MRR, CSAT, resolution time, refunds
- **Visuals:** Monthly sign-up growth, cumulative growth, plan/industry mix, MRR box plot by plan, churn rate by referral source, ticket volume by priority
- Saves 5 cleaned CSVs to `data/processed/`

### 02_cohort_analysis.ipynb — Cohort Retention
- Builds cohort base table (account × cohort_month × active_month)
- Computes period_number using Period arithmetic
- Pivots into retention matrix (accounts × months)
- **Visuals:** Full retention heatmap (colour-scaled, annotated), average retention curve with key period callouts, retention by referral source (grouped bar), NRR curve vs. 100% baseline
- Exports `cohort_retention_pct.csv` and `cohort_nrr_pct.csv`

### 03_churn_analysis.ipynb — Churn Analysis
- Computes gross churn rate, MRR churn rate, reactivation rate
- Monthly churn trend with active account base denominator
- Churn reason decomposition (volume + refund amounts)
- Churn rate by plan tier and industry
- **Visuals:** Monthly churn bar + rate dual-axis, churn reasons horizontal bar, churn by segment (plan + industry), time-to-churn histogram + box by plan, support load comparison (churned vs. retained density plot)
- Exports `monthly_churn_summary.csv`, `churn_reason_summary.csv`, `churn_by_plan.csv`

### 04_business_insights.ipynb — Business Insights
- Revenue trend analysis: stacked MRR by plan, MoM growth rate bar
- Feature adoption: breadth ranking + adoption × engagement bubble chart
- Support performance: 2×2 dashboard (CSAT trend, resolution trend, priority pie, CSAT distribution)
- **One-page executive dashboard visual** (6-panel composite figure)
- Dynamic findings computation: top churn reason, best channel, pre-churn ticket ratio
- Exports `final_metrics_summary.csv`

---

## Power BI Dashboard

The dashboard contains **5 pages**, built using the DAX measures and layout guide in `dashboard/Startup_Growth_Analytics_Dashboard_Guide.md`.

| Page | Content |
|---|---|
| **Executive Overview** | KPI cards (total accounts, active, MRR, ARR, churn rate), MRR trend, plan mix donut, monthly signups, top churn reasons |
| **Revenue Analytics** | Stacked MRR by plan, ARR by industry treemap, revenue by country map, MoM waterfall, top 10 accounts table |
| **Retention & Churn** | Monthly churn trend, churn by reason donut, churn by plan/industry bars, reactivation KPI, cohort retention matrix |
| **Product Usage** | Top features by adoption, beta vs. GA split, usage trend, feature error rate, usage by plan tier matrix |
| **Support Analytics** | CSAT trend, resolution time trend, priority distribution pie, CSAT score distribution, SLA compliance bar |

### Dashboard Screenshots

> Run the Python notebooks to generate all visuals in `visuals/`, then refer to them when building the Power BI report.

| Visual | File |
|---|---|
| Executive Dashboard | `visuals/00_executive_dashboard.png` |
| Customer Growth | `visuals/01_customer_growth.png` |
| Plan & Industry Mix | `visuals/02_plan_industry_mix.png` |
| MRR by Plan | `visuals/03_mrr_by_plan.png` |
| Churn by Referral | `visuals/04_churn_by_referral.png` |
| Ticket Volume | `visuals/05_ticket_volume.png` |
| Cohort Heatmap | `visuals/06_cohort_retention_heatmap.png` |
| Retention Curve | `visuals/07_avg_retention_curve.png` |
| Retention by Channel | `visuals/08_retention_by_referral.png` |
| NRR Curve | `visuals/09_nrr_curve.png` |
| Monthly Churn Trend | `visuals/10_monthly_churn_trend.png` |
| Churn Reasons | `visuals/11_churn_reasons.png` |
| Churn by Segment | `visuals/12_churn_by_segment.png` |
| Time-to-Churn | `visuals/13_time_to_churn.png` |
| Support vs Churn | `visuals/14_support_vs_churn.png` |
| MRR Trend | `visuals/15_mrr_trend.png` |
| Feature Adoption | `visuals/16_feature_adoption.png` |
| Support Dashboard | `visuals/17_support_dashboard.png` |

---

## Key Findings

1. **Pricing is the #1 churn driver** — accounts for ~25–30% of all churn events, with the highest average MRR loss per event. The pricing gap between Basic and Pro tiers is forcing mid-market customers out.

2. **Month 1–3 is the critical retention window** — average retention drops from ~72% at M1 to ~54% at M3. The steepest drop happens in the first 60 days, before most customers reach activation.

3. **Partner and organic channels retain best** — accounts acquired through partner and organic channels show 5–8 percentage points lower churn rates than paid acquisition channels.

4. **High support load predicts churn** — churned accounts raised ~40% more support tickets in their final 30 days compared to retained accounts. Escalated tickets show the strongest churn correlation.

5. **Enterprise accounts have the lowest churn rate** — but Basic plan accounts (the largest segment) churn fastest, making the overall blended churn rate appear worse than the high-value segments.

6. **Feature adoption is concentrated** — the top 10 of 40 features account for the majority of usage. Several features have error rates above 5%, which suppresses engagement.

7. **Support SLA compliance is below target** — only ~62% of urgent tickets receive a first response within the 30-minute target, contributing to low CSAT scores for high-priority issues.

8. **10% of churn events are reactivations** — indicating a win-back opportunity that is currently unmanaged.

---

## Business Recommendations

> Full details with supporting numbers in [`reports/business_recommendations.md`](reports/business_recommendations.md)

| # | Recommendation | Priority | Impact |
|---|---|---|---|
| 1 | Introduce a mid-tier pricing plan; push annual billing discounts | P1 | Very High |
| 2 | Build a 30-day structured onboarding sequence for new accounts | P1 | Very High |
| 3 | Implement a churn early-warning system using support + usage signals | P1 | High |
| 4 | Shift acquisition budget toward partner and organic channels | P2 | Medium |
| 5 | Fix high-error-rate features in next sprint cycle | P2 | Medium |
| 6 | Improve urgent ticket SLA compliance through shift staffing | P2 | Medium |
| 7 | Launch a win-back email programme for eligible churned accounts | P3 | Low-Medium |

---

## Getting Started

### Prerequisites
- Python 3.9+
- PostgreSQL 14+ (optional — SQL files work standalone)
- Power BI Desktop (for dashboard)
- Jupyter Lab or VS Code with Jupyter extension

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/startup-growth-analytics.git
cd startup-growth-analytics

# Install Python dependencies
pip install -r requirements.txt
```

### Running the Notebooks (in order)

```bash
# Launch Jupyter
jupyter lab

# Run in this order:
# 1. notebooks/01_eda.ipynb          ← creates data/processed/ files
# 2. notebooks/02_cohort_analysis.ipynb
# 3. notebooks/03_churn_analysis.ipynb
# 4. notebooks/04_business_insights.ipynb
```

> **Important:** Run `01_eda.ipynb` first — it creates the cleaned CSVs in `data/processed/` that all subsequent notebooks depend on.

### Setting Up PostgreSQL (Optional)

```sql
-- In psql, create the database
CREATE DATABASE ravenstack_analytics;
\c ravenstack_analytics

-- Run scripts in order
\i sql/schema.sql
-- Edit data paths in data_load.sql, then:
\i sql/data_load.sql

-- Run individual analysis scripts
\i sql/revenue_analysis.sql
\i sql/churn_analysis.sql
\i sql/cohort_analysis.sql
\i sql/feature_adoption.sql
\i sql/support_analysis.sql
```

---

## Future Improvements

1. **Customer Health Score model** — Build a weighted scoring system using feature usage, support load, and billing behaviour to produce a monthly health score per account. No ML needed; pure SQL + Python aggregation.

2. **Revenue Waterfall Automation** — Automate the new/expansion/contraction/churned MRR waterfall as a scheduled SQL report, formatted for monthly stakeholder distribution.

3. **Looker Studio / Tableau version** — Rebuild the Power BI dashboard in an open-source BI tool to make the project accessible without a Power BI Pro licence.

4. **Automated data refresh pipeline** — Replace manual CSV loads with a simple Python `psycopg2` script that upserts new data on a schedule, making the dashboard refresh-ready.

5. **Deeper feature-retention correlation** — Cross-tabulate specific feature usage patterns with M6 retention rates to identify the product's "aha moment" features.

6. **Geographic deep-dive** — Expand the country-level analysis with a choropleth map showing churn rate and MRR density by region.

---

## Credits

- **Dataset:** [RavenStack Synthetic SaaS Dataset](https://rivalytics.medium.com) by **River @ Rivalytics** — used and credited per MIT-like license terms.
- **Tech Stack:** PostgreSQL, Python (Pandas, NumPy, Matplotlib), Power BI
- **Project Type:** Data Analytics Portfolio Project

---

<div align="center">
  <i>Built as a professional Data Analytics portfolio project. All data is fully synthetic.</i>
</div>
#   m e r a b a d l a  
 