

CREATE OR REPLACE VIEW v_account_cohorts AS
SELECT
    account_id,
    DATE_TRUNC('month', signup_date)::date AS cohort_month
FROM   accounts;



WITH cohort_base AS (
    SELECT
        ac.account_id,
        ac.cohort_month,
        DATE_TRUNC('month', s.start_date)::date AS active_month
    FROM   v_account_cohorts ac
    JOIN   subscriptions s ON ac.account_id = s.account_id
    WHERE  s.is_trial = FALSE
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT account_id) AS cohort_size
    FROM   v_account_cohorts
    GROUP  BY cohort_month
),
retention_raw AS (
    SELECT
        cb.cohort_month,
        cb.active_month,
        (
            EXTRACT(YEAR  FROM cb.active_month) * 12 +
            EXTRACT(MONTH FROM cb.active_month)
        ) - (
            EXTRACT(YEAR  FROM cb.cohort_month) * 12 +
            EXTRACT(MONTH FROM cb.cohort_month)
        )                                             AS period_number,
        COUNT(DISTINCT cb.account_id)                 AS retained_accounts
    FROM   cohort_base cb
    GROUP  BY cb.cohort_month, cb.active_month
)
SELECT
    rr.cohort_month,
    cs.cohort_size,
    rr.period_number,
    rr.retained_accounts,
    ROUND(rr.retained_accounts * 100.0 / NULLIF(cs.cohort_size, 0), 1) AS retention_rate_pct
FROM   retention_raw rr
JOIN   cohort_sizes  cs ON rr.cohort_month = cs.cohort_month
ORDER  BY rr.cohort_month, rr.period_number;


WITH cohort_base AS (
    SELECT
        a.account_id,
        a.referral_source,
        DATE_TRUNC('month', a.signup_date)::date      AS cohort_month,
        DATE_TRUNC('month', s.start_date)::date        AS active_month
    FROM   accounts a
    JOIN   subscriptions s ON a.account_id = s.account_id
    WHERE  s.is_trial = FALSE
),
cohort_sizes AS (
    SELECT
        referral_source,
        cohort_month,
        COUNT(DISTINCT account_id) AS cohort_size
    FROM   cohort_base
    GROUP  BY referral_source, cohort_month
),
retention_raw AS (
    SELECT
        cb.referral_source,
        cb.cohort_month,
        (
            EXTRACT(YEAR  FROM cb.active_month) * 12 +
            EXTRACT(MONTH FROM cb.active_month)
        ) - (
            EXTRACT(YEAR  FROM cb.cohort_month) * 12 +
            EXTRACT(MONTH FROM cb.cohort_month)
        )                                         AS period_number,
        COUNT(DISTINCT cb.account_id)             AS retained_accounts
    FROM   cohort_base cb
    GROUP  BY cb.referral_source, cb.cohort_month, cb.active_month
)
SELECT
    rr.referral_source,
    rr.cohort_month,
    cs.cohort_size,
    rr.period_number,
    rr.retained_accounts,
    ROUND(rr.retained_accounts * 100.0 / NULLIF(cs.cohort_size, 0), 1) AS retention_pct
FROM   retention_raw rr
JOIN   cohort_sizes  cs
    ON rr.referral_source = cs.referral_source
   AND rr.cohort_month    = cs.cohort_month
WHERE  rr.period_number BETWEEN 0 AND 6
ORDER  BY rr.referral_source, rr.cohort_month, rr.period_number;


WITH cohort_mrr AS (
    SELECT
        DATE_TRUNC('month', a.signup_date)::date      AS cohort_month,
        DATE_TRUNC('month', s.start_date)::date        AS active_month,
        SUM(s.mrr_amount)                              AS mrr
    FROM   accounts a
    JOIN   subscriptions s ON a.account_id = s.account_id
    WHERE  s.is_trial = FALSE AND s.mrr_amount > 0
    GROUP  BY DATE_TRUNC('month', a.signup_date),
              DATE_TRUNC('month', s.start_date)
),
cohort_base_mrr AS (
    SELECT cohort_month, mrr AS base_mrr
    FROM   cohort_mrr
)
SELECT
    cm.cohort_month,
    (
        EXTRACT(YEAR  FROM cm.active_month) * 12 +
        EXTRACT(MONTH FROM cm.active_month)
    ) - (
        EXTRACT(YEAR  FROM cm.cohort_month) * 12 +
        EXTRACT(MONTH FROM cm.cohort_month)
    )                                                 AS period_number,
    ROUND(cm.mrr, 2)                                  AS cohort_mrr,
    ROUND(cb.base_mrr, 2)                             AS base_mrr,
    ROUND(cm.mrr * 100.0 / NULLIF(cb.base_mrr, 0), 1) AS net_revenue_retention_pct
FROM   cohort_mrr cm
JOIN   cohort_base_mrr cb ON cm.cohort_month = cb.cohort_month
ORDER  BY cm.cohort_month, period_number;


WITH cohort_base AS (
    SELECT
        a.account_id,
        DATE_TRUNC('month', a.signup_date)::date      AS cohort_month,
        DATE_TRUNC('month', s.start_date)::date        AS active_month
    FROM   accounts a
    JOIN   subscriptions s ON a.account_id = s.account_id
    WHERE  s.is_trial = FALSE
    GROUP  BY a.account_id, DATE_TRUNC('month', a.signup_date),
              DATE_TRUNC('month', s.start_date)
),
cohort_sizes AS (
    SELECT
        DATE_TRUNC('month', signup_date)::date AS cohort_month,
        COUNT(*)                                AS cohort_size
    FROM   accounts
    GROUP  BY DATE_TRUNC('month', signup_date)
)
SELECT
    cb.cohort_month,
    cs.cohort_size,
    ROUND(COUNT(DISTINCT CASE WHEN
        (EXTRACT(YEAR FROM cb.active_month)*12 + EXTRACT(MONTH FROM cb.active_month)) -
        (EXTRACT(YEAR FROM cb.cohort_month)*12 + EXTRACT(MONTH FROM cb.cohort_month)) = 1
        THEN cb.account_id END) * 100.0 / NULLIF(cs.cohort_size,0), 1) AS m1_pct,
    ROUND(COUNT(DISTINCT CASE WHEN
        (EXTRACT(YEAR FROM cb.active_month)*12 + EXTRACT(MONTH FROM cb.active_month)) -
        (EXTRACT(YEAR FROM cb.cohort_month)*12 + EXTRACT(MONTH FROM cb.cohort_month)) = 3
        THEN cb.account_id END) * 100.0 / NULLIF(cs.cohort_size,0), 1) AS m3_pct,
    ROUND(COUNT(DISTINCT CASE WHEN
        (EXTRACT(YEAR FROM cb.active_month)*12 + EXTRACT(MONTH FROM cb.active_month)) -
        (EXTRACT(YEAR FROM cb.cohort_month)*12 + EXTRACT(MONTH FROM cb.cohort_month)) = 6
        THEN cb.account_id END) * 100.0 / NULLIF(cs.cohort_size,0), 1) AS m6_pct
FROM   cohort_base cb
JOIN   cohort_sizes cs ON cb.cohort_month = cs.cohort_month
GROUP  BY cb.cohort_month, cs.cohort_size
ORDER  BY cb.cohort_month;


WITH cohort_base AS (
    SELECT
        ac.account_id,
        ac.cohort_month,
        DATE_TRUNC('month', s.start_date)::date AS active_month
    FROM   v_account_cohorts ac
    JOIN   subscriptions s ON ac.account_id = s.account_id
    WHERE  s.is_trial = FALSE
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT account_id) AS cohort_size
    FROM   v_account_cohorts
    GROUP  BY cohort_month
),
retention_raw AS (
    SELECT
        cb.cohort_month,
        (
            EXTRACT(YEAR  FROM cb.active_month)*12 + EXTRACT(MONTH FROM cb.active_month)
        ) - (
            EXTRACT(YEAR  FROM cb.cohort_month)*12 + EXTRACT(MONTH FROM cb.cohort_month)
        )                               AS period_number,
        COUNT(DISTINCT cb.account_id)   AS retained
    FROM   cohort_base cb
    GROUP  BY cb.cohort_month, cb.active_month
)
SELECT
    rr.period_number,
    COUNT(DISTINCT rr.cohort_month)                                      AS cohorts_observed,
    ROUND(AVG(rr.retained * 100.0 / NULLIF(cs.cohort_size, 0)), 1)      AS avg_retention_pct,
    ROUND(MIN(rr.retained * 100.0 / NULLIF(cs.cohort_size, 0)), 1)      AS min_retention_pct,
    ROUND(MAX(rr.retained * 100.0 / NULLIF(cs.cohort_size, 0)), 1)      AS max_retention_pct
FROM   retention_raw rr
JOIN   cohort_sizes  cs ON rr.cohort_month = cs.cohort_month
WHERE  rr.period_number BETWEEN 1 AND 12
GROUP  BY rr.period_number
ORDER  BY rr.period_number;
