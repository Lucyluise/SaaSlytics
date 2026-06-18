# Power BI Dashboard Guide
## Startup Growth Analytics: SaaS Subscription & Churn Analysis

**Tool:** Microsoft Power BI Desktop  
**Data Source:** CSVs from `data/processed/` + `data/raw/`  
**File:** `dashboard/Startup_Growth_Analytics.pbix`

---

## Setup Instructions

### Step 1 — Connect Data Sources
1. Open Power BI Desktop → **Get Data → Text/CSV**
2. Import all five processed CSVs from `data/processed/`:
   - `accounts_clean.csv`
   - `subscriptions_clean.csv`
   - `feature_usage_clean.csv`
   - `support_tickets_clean.csv`
   - `churn_events_clean.csv`

### Step 2 — Configure Relationships (Model View)
Set up the following relationships in the **Model** view:

| From Table | From Column | To Table | To Column | Cardinality |
|---|---|---|---|---|
| subscriptions | account_id | accounts | account_id | Many-to-One |
| feature_usage | subscription_id | subscriptions | subscription_id | Many-to-One |
| support_tickets | account_id | accounts | account_id | Many-to-One |
| churn_events | account_id | accounts | account_id | Many-to-One |

### Step 3 — Data Type Fixes
In **Transform Data (Power Query)**:
- `signup_date`, `start_date`, `end_date`, `churn_date`, `submitted_at`, `closed_at` → **Date/DateTime**
- `mrr_amount`, `arr_amount`, `refund_amount_usd` → **Decimal Number**
- `churn_flag`, `is_trial`, `escalation_flag` → **True/False**

---

## DAX Measures

Create a dedicated **Measures** table for all DAX calculations.

### Page 1 — Executive Overview

```dax
-- Total Accounts
Total Accounts = COUNTROWS(accounts)

-- Active Accounts (not churned)
Active Accounts =
CALCULATE(
    COUNTROWS(accounts),
    accounts[churn_flag] = FALSE
)

-- Current MRR (active, paid subscriptions)
Current MRR =
CALCULATE(
    SUM(subscriptions[mrr_amount]),
    subscriptions[churn_flag] = FALSE,
    subscriptions[is_trial]   = FALSE,
    subscriptions[mrr_amount] > 0
)

-- Current ARR
Current ARR = [Current MRR] * 12

-- Gross Churn Rate
Gross Churn Rate =
DIVIDE(
    CALCULATE(COUNTROWS(accounts), accounts[churn_flag] = TRUE),
    COUNTROWS(accounts)
)

-- Trial Rate
Trial Rate =
DIVIDE(
    CALCULATE(COUNTROWS(accounts), accounts[is_trial] = TRUE),
    COUNTROWS(accounts)
)
```

### Page 2 — Revenue Analytics

```dax
-- Total Historical MRR
Total Historical MRR =
CALCULATE(
    SUM(subscriptions[mrr_amount]),
    subscriptions[is_trial]   = FALSE,
    subscriptions[mrr_amount] > 0
)

-- MRR by Plan Tier (use slicer/legend)
MRR by Plan =
CALCULATE(
    SUM(subscriptions[mrr_amount]),
    subscriptions[is_trial] = FALSE
)

-- Average MRR per Subscription
Avg MRR per Sub =
AVERAGEX(
    FILTER(subscriptions, subscriptions[mrr_amount] > 0 && NOT(subscriptions[is_trial])),
    subscriptions[mrr_amount]
)

-- Month-over-Month MRR Growth
MoM MRR Growth =
VAR CurrentMRR = [Current MRR]
VAR PrevMRR =
    CALCULATE(
        [Current MRR],
        DATEADD('Date'[Date], -1, MONTH)
    )
RETURN DIVIDE(CurrentMRR - PrevMRR, PrevMRR)
```

### Page 3 — Retention & Churn

```dax
-- Total Churn Events
Total Churn Events = COUNTROWS(churn_events)

-- MRR Lost to Churn
MRR Lost to Churn =
CALCULATE(
    SUM(subscriptions[mrr_amount]),
    subscriptions[churn_flag] = TRUE
)

-- Reactivation Count
Reactivations =
CALCULATE(
    COUNTROWS(churn_events),
    churn_events[is_reactivation] = TRUE
)

-- Average Days to Churn
Avg Days to Churn =
AVERAGEX(
    ADDCOLUMNS(
        churn_events,
        "TenureDays",
        DATEDIFF(
            RELATED(accounts[signup_date]),
            churn_events[churn_date],
            DAY
        )
    ),
    [TenureDays]
)
```

### Page 4 — Product Usage

```dax
-- Total Usage Events
Total Usage Events = COUNTROWS(feature_usage)

-- Unique Features Used
Unique Features = DISTINCTCOUNT(feature_usage[feature_name])

-- Total Usage Count
Total Usage Count = SUM(feature_usage[usage_count])

-- Avg Session Duration (mins)
Avg Session Duration Mins =
DIVIDE(
    AVERAGE(feature_usage[usage_duration_secs]),
    60
)

-- Feature Error Rate
Feature Error Rate =
DIVIDE(
    SUM(feature_usage[error_count]),
    SUM(feature_usage[usage_count])
)

-- Beta Feature Usage Share
Beta Feature Share =
DIVIDE(
    CALCULATE(COUNTROWS(feature_usage), feature_usage[is_beta_feature] = TRUE),
    COUNTROWS(feature_usage)
)
```

### Page 5 — Support Analytics

```dax
-- Total Tickets
Total Tickets = COUNTROWS(support_tickets)

-- Avg Resolution Time
Avg Resolution Hours = AVERAGE(support_tickets[resolution_time_hours])

-- Avg CSAT Score
Avg CSAT =
CALCULATE(
    AVERAGE(support_tickets[satisfaction_score]),
    NOT(ISBLANK(support_tickets[satisfaction_score]))
)

-- Escalation Rate
Escalation Rate =
DIVIDE(
    CALCULATE(COUNTROWS(support_tickets), support_tickets[escalation_flag] = TRUE),
    COUNTROWS(support_tickets)
)

-- CSAT Response Rate
CSAT Response Rate =
DIVIDE(
    CALCULATE(COUNTROWS(support_tickets), NOT(ISBLANK(support_tickets[satisfaction_score]))),
    COUNTROWS(support_tickets)
)

-- % Promoters (CSAT 4-5)
Promoter Rate =
DIVIDE(
    CALCULATE(COUNTROWS(support_tickets), support_tickets[satisfaction_score] >= 4),
    CALCULATE(COUNTROWS(support_tickets), NOT(ISBLANK(support_tickets[satisfaction_score])))
)
```

---

## Dashboard Pages — Layout Guide

### Page 1: Executive Overview
| Visual | Type | Fields |
|---|---|---|
| Total Accounts KPI card | Card | `Total Accounts` |
| Active Accounts KPI card | Card | `Active Accounts` |
| Current MRR KPI card | Card | `Current MRR` |
| Current ARR KPI card | Card | `Current ARR` |
| Gross Churn Rate KPI card | Card | `Gross Churn Rate` |
| MRR trend line chart | Line | X: start_date (Month), Y: `Current MRR` |
| Accounts by Plan donut | Donut | Legend: plan_tier, Values: count |
| New Signups by Month | Bar | X: signup_date (Month), Y: count |
| Churn by Reason | Bar | X: reason_code, Y: count |

### Page 2: Revenue Analytics
| Visual | Type | Fields |
|---|---|---|
| MRR by Month + Plan (stacked bar) | Stacked Bar | X: Month, Y: MRR, Legend: plan_tier |
| ARR by Industry | Treemap | Group: industry, Value: arr_amount |
| Revenue by Country (map) | Filled Map | Location: country, Size: mrr_amount |
| MoM Growth waterfall | Waterfall | Categories: month, Y: MoM growth |
| Top 10 Accounts by Revenue | Table | account_name, plan_tier, mrr_amount |

### Page 3: Retention & Churn
| Visual | Type | Fields |
|---|---|---|
| Churn Rate by Month (line) | Line | X: churn_date (Month), Y: count |
| Churn by Reason (donut) | Donut | Legend: reason_code, Values: count |
| Churn by Plan Tier (bar) | Bar | X: plan_tier, Y: churn rate % |
| Churn by Industry (bar) | Bar | X: industry, Y: churn rate % |
| Reactivations KPI card | Card | `Reactivations` |
| Cohort Matrix (matrix visual) | Matrix | Rows: cohort_month, Cols: period_number, Values: retention % |

> **Cohort Matrix Tip:** Load `cohort_retention_pct.csv` from `data/processed/` directly as a separate table for the cohort heatmap. Use conditional formatting (colour scale: red → green) on the matrix values.

### Page 4: Product Usage
| Visual | Type | Fields |
|---|---|---|
| Top Features by Usage (bar) | Bar | X: feature_name, Y: usage_count |
| Feature Adoption Rate | Bar | X: feature_name, Y: unique subscription count |
| Beta vs GA Usage (stacked) | Stacked Bar | X: month, Y: events, Legend: is_beta_feature |
| Usage Trend over Time | Line | X: usage_date (Month), Y: usage_count |
| Feature Error Rate (bar) | Bar | X: feature_name, Y: error_rate |
| Usage by Plan Tier (matrix) | Matrix | Rows: feature_name, Cols: plan_tier, Values: count |

### Page 5: Support Analytics
| Visual | Type | Fields |
|---|---|---|
| Total Tickets KPI card | Card | `Total Tickets` |
| Avg CSAT KPI card | Card | `Avg CSAT` |
| Avg Resolution Time KPI card | Card | `Avg Resolution Hours` |
| Escalation Rate KPI card | Card | `Escalation Rate` |
| Monthly Ticket Volume (bar) | Bar | X: submitted_at (Month), Y: count |
| CSAT Trend (line) | Line | X: submitted_at (Month), Y: avg CSAT |
| Resolution by Priority (bar) | Clustered Bar | X: priority, Y: avg resolution hours |
| CSAT Distribution (bar) | Bar | X: satisfaction_score (1–5), Y: count |
| SLA Compliance by Priority | Bar | X: priority, Y: % within SLA |

---

## Theme & Formatting Tips
- **Background colour:** `#0f1117` (dark navy)
- **Card accent colour:** `#58a6ff` (GitHub blue)
- **Positive metric colour:** `#3fb950` (green)
- **Negative/churn colour:** `#f78166` (red-orange)
- **Font:** Segoe UI or DIN
- **Enable grid lines** on all charts for readability
- Use **conditional formatting** on churn rate cards (green < 10%, amber 10–20%, red > 20%)

---

## Slicers to Add (Global Filters)
- `signup_date` → date range slicer
- `plan_tier` → dropdown slicer
- `industry` → dropdown slicer
- `country` → dropdown slicer
- `referral_source` → dropdown slicer
- `billing_frequency` → toggle slicer

---

*Note: A `.pbix` file is a binary format that cannot be generated programmatically. Use the DAX measures and layout guide above to build the dashboard directly in Power BI Desktop. Estimated build time: 3–4 hours.*
