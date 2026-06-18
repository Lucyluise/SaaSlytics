WITH calendar AS (
    SELECT generate_series(
               DATE_TRUNC('month', '2023-01-01'::date),
               DATE_TRUNC('month', '2025-12-01'::date),
               '1 month'::interval
           )::date AS month_start
),
active_subs AS (
    SELECT
        s.subscription_id,
        s.account_id,
        s.start_date,
        COALESCE(s.end_date, '2099-12-31'::date) AS effective_end_date,
        s.plan_tier,
        s.mrr_amount,
        s.billing_frequency
    FROM subscriptions s
    WHERE s.is_trial = FALSE
      AND s.mrr_amount > 0
)
SELECT
    c.month_start                                  AS month,
    COUNT(DISTINCT a.subscription_id)              AS active_subscriptions,
    COUNT(DISTINCT a.account_id)                   AS active_accounts,
    ROUND(SUM(a.mrr_amount), 2)                    AS total_mrr,
    ROUND(SUM(a.mrr_amount) * 12, 2)               AS implied_arr
FROM   calendar c
JOIN   active_subs a
    ON c.month_start >= DATE_TRUNC('month', a.start_date)
   AND c.month_start <  DATE_TRUNC('month', a.effective_end_date)
GROUP  BY c.month_start
ORDER  BY c.month_start;


WITH calendar AS (
    SELECT generate_series(
               DATE_TRUNC('month', '2023-01-01'::date),
               DATE_TRUNC('month', '2025-12-01'::date),
               '1 month'::interval
           )::date AS month_start
),
active_subs AS (
    SELECT
        subscription_id,
        start_date,
        COALESCE(end_date, '2099-12-31'::date) AS effective_end_date,
        plan_tier,
        mrr_amount
    FROM subscriptions
    WHERE is_trial = FALSE AND mrr_amount > 0
)
SELECT
    c.month_start   AS month,
    a.plan_tier,
    ROUND(SUM(a.mrr_amount), 2) AS mrr,
    COUNT(DISTINCT a.subscription_id) AS subscriptions
FROM   calendar c
JOIN   active_subs a
    ON c.month_start >= DATE_TRUNC('month', a.start_date)
   AND c.month_start <  DATE_TRUNC('month', a.effective_end_date)
GROUP  BY c.month_start, a.plan_tier
ORDER  BY c.month_start, a.plan_tier;


WITH monthly_mrr AS (
    SELECT
        subscription_id,
        account_id,
        plan_tier,
        mrr_amount,
        DATE_TRUNC('month', start_date)::date     AS cohort_month,
        upgrade_flag,
        downgrade_flag,
        churn_flag,
        is_trial
    FROM subscriptions
    WHERE is_trial = FALSE AND mrr_amount > 0
)
SELECT
    cohort_month                                           AS month,
    ROUND(SUM(mrr_amount), 2)                              AS new_mrr,
    ROUND(SUM(CASE WHEN upgrade_flag   THEN mrr_amount ELSE 0 END), 2) AS expansion_mrr,
    ROUND(SUM(CASE WHEN downgrade_flag THEN mrr_amount ELSE 0 END), 2) AS contraction_mrr,
    (
        SELECT ROUND(SUM(m2.mrr_amount), 2)
        FROM   monthly_mrr m2
        WHERE  m2.churn_flag = TRUE
          AND  DATE_TRUNC('month', m2.end_date)::date = monthly_mrr.cohort_month
    )                                                       AS churned_mrr
FROM   monthly_mrr
GROUP  BY cohort_month
ORDER  BY cohort_month;


SELECT
    a.industry,
    COUNT(DISTINCT a.account_id)        AS accounts,
    COUNT(DISTINCT s.subscription_id)   AS subscriptions,
    ROUND(SUM(s.mrr_amount), 2)         AS total_mrr,
    ROUND(AVG(s.mrr_amount), 2)         AS avg_mrr_per_sub,
    ROUND(SUM(s.arr_amount), 2)         AS total_arr
FROM   accounts a
JOIN   subscriptions s ON a.account_id = s.account_id
WHERE  s.is_trial = FALSE AND s.mrr_amount > 0
GROUP  BY a.industry
ORDER  BY total_mrr DESC;


SELECT
    a.country,
    COUNT(DISTINCT a.account_id)        AS accounts,
    ROUND(SUM(s.mrr_amount), 2)         AS total_mrr,
    ROUND(SUM(s.arr_amount), 2)         AS total_arr,
    ROUND(AVG(s.mrr_amount), 2)         AS avg_mrr
FROM   accounts a
JOIN   subscriptions s ON a.account_id = s.account_id
WHERE  s.is_trial = FALSE AND s.mrr_amount > 0
GROUP  BY a.country
ORDER  BY total_mrr DESC
LIMIT  15;


SELECT
    a.account_id,
    a.account_name,
    a.industry,
    a.plan_tier                                                           AS current_plan,
    COUNT(DISTINCT s.subscription_id)                                     AS subscription_count,
    ROUND(SUM(s.mrr_amount), 2)                                           AS lifetime_mrr,
    ROUND(SUM(s.arr_amount), 2)                                           AS lifetime_arr,
    MIN(s.start_date)                                                      AS first_sub_date,
    MAX(COALESCE(s.end_date, CURRENT_DATE))                                AS latest_activity,
    (MAX(COALESCE(s.end_date, CURRENT_DATE)) - MIN(s.start_date))         AS tenure_days
FROM   accounts a
JOIN   subscriptions s ON a.account_id = s.account_id
WHERE  s.is_trial = FALSE AND s.mrr_amount > 0
GROUP  BY a.account_id, a.account_name, a.industry, a.plan_tier
ORDER  BY lifetime_arr DESC
LIMIT  20;


SELECT
    billing_frequency,
    COUNT(*)                              AS subscription_count,
    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER (), 1)       AS pct_of_subs,
    ROUND(SUM(mrr_amount), 2)             AS total_mrr,
    ROUND(SUM(mrr_amount) * 100.0 /
          SUM(SUM(mrr_amount)) OVER (), 1) AS pct_of_mrr
FROM   subscriptions
WHERE  is_trial = FALSE AND mrr_amount > 0
GROUP  BY billing_frequency
ORDER  BY total_mrr DESC;


WITH monthly_mrr AS (
    SELECT
        DATE_TRUNC('month', start_date)::date AS month,
        SUM(mrr_amount)                        AS mrr
    FROM   subscriptions
    WHERE  is_trial = FALSE AND mrr_amount > 0
      AND  start_date >= '2023-01-01'
    GROUP  BY DATE_TRUNC('month', start_date)
)
SELECT
    month,
    ROUND(mrr, 2)                                            AS mrr,
    ROUND(LAG(mrr) OVER (ORDER BY month), 2)                 AS prev_month_mrr,
    ROUND(
        (mrr - LAG(mrr) OVER (ORDER BY month))
        / NULLIF(LAG(mrr) OVER (ORDER BY month), 0) * 100, 2
    )                                                        AS mom_growth_pct
FROM   monthly_mrr
ORDER  BY month;


SELECT
    plan_tier,
    COUNT(*)                      AS active_subscriptions,
    ROUND(SUM(mrr_amount), 2)     AS current_mrr,
    ROUND(SUM(arr_amount), 2)     AS current_arr,
    ROUND(AVG(mrr_amount), 2)     AS avg_mrr,
    ROUND(AVG(seats), 1)          AS avg_seats
FROM   subscriptions
WHERE  churn_flag = FALSE
  AND  is_trial   = FALSE
  AND  mrr_amount > 0
GROUP  BY plan_tier
ORDER  BY current_arr DESC;
