

SELECT
    COUNT(DISTINCT a.account_id)                        AS total_accounts,
    COUNT(DISTINCT ce.account_id)                       AS churned_accounts,
    ROUND(
        COUNT(DISTINCT ce.account_id) * 100.0 /
        NULLIF(COUNT(DISTINCT a.account_id), 0), 2
    )                                                    AS gross_churn_rate_pct,
    COUNT(DISTINCT CASE WHEN ce.is_reactivation THEN ce.account_id END)
                                                         AS reactivations
FROM   accounts a
LEFT   JOIN churn_events ce ON a.account_id = ce.account_id;


WITH monthly_signups AS (
    SELECT
        DATE_TRUNC('month', signup_date)::date AS month,
        COUNT(*)                                AS new_accounts
    FROM   accounts
    GROUP  BY DATE_TRUNC('month', signup_date)
),
monthly_churns AS (
    SELECT
        DATE_TRUNC('month', churn_date)::date  AS month,
        COUNT(DISTINCT account_id)              AS churned_accounts,
        ROUND(SUM(CASE WHEN refund_amount_usd > 0 THEN refund_amount_usd ELSE 0 END), 2) AS refunds_issued
    FROM   churn_events
    GROUP  BY DATE_TRUNC('month', churn_date)
),
spine AS (
    SELECT generate_series(
               '2023-01-01'::date,
               '2025-12-01'::date,
               '1 month'::interval
           )::date AS month
)
SELECT
    sp.month,
    COALESCE(ns.new_accounts, 0)       AS new_accounts,
    COALESCE(mc.churned_accounts, 0)   AS churned_accounts,
    COALESCE(mc.refunds_issued, 0)     AS refunds_issued,
    SUM(COALESCE(ns.new_accounts, 0))
        OVER (ORDER BY sp.month)       AS cumulative_accounts,
    ROUND(
        COALESCE(mc.churned_accounts, 0) * 100.0 /
        NULLIF(
            SUM(COALESCE(ns.new_accounts, 0)) OVER (ORDER BY sp.month) -
            SUM(COALESCE(mc.churned_accounts, 0)) OVER (ORDER BY sp.month) +
            COALESCE(mc.churned_accounts, 0),
            0
        ), 2
    )                                  AS monthly_churn_rate_pct
FROM   spine sp
LEFT   JOIN monthly_signups ns ON sp.month = ns.month
LEFT   JOIN monthly_churns  mc ON sp.month = mc.month
ORDER  BY sp.month;


SELECT
    ce.reason_code,
    COUNT(*)                                    AS churn_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_churns,
    ROUND(SUM(ce.refund_amount_usd), 2)         AS total_refunds,
    ROUND(AVG(ce.refund_amount_usd), 2)         AS avg_refund,
    COUNT(CASE WHEN ce.is_reactivation THEN 1 END) AS reactivations,
    ROUND(SUM(s.mrr_amount), 2)                 AS mrr_lost
FROM   churn_events ce
LEFT   JOIN LATERAL (
    SELECT mrr_amount
    FROM   subscriptions sub
    WHERE  sub.account_id = ce.account_id
      AND  sub.churn_flag = TRUE
    ORDER  BY sub.end_date DESC
    LIMIT  1
) s ON TRUE
GROUP  BY ce.reason_code
ORDER  BY churn_count DESC;


SELECT
    a.plan_tier,
    COUNT(DISTINCT a.account_id)            AS total_accounts,
    COUNT(DISTINCT ce.account_id)           AS churned_accounts,
    ROUND(
        COUNT(DISTINCT ce.account_id) * 100.0 /
        NULLIF(COUNT(DISTINCT a.account_id), 0), 2
    )                                        AS churn_rate_pct,
    ROUND(AVG(s.mrr_amount), 2)             AS avg_mrr_at_churn
FROM   accounts a
LEFT   JOIN churn_events ce ON a.account_id = ce.account_id
LEFT   JOIN subscriptions s ON s.account_id = a.account_id
              AND s.churn_flag = TRUE
GROUP  BY a.plan_tier
ORDER  BY churn_rate_pct DESC;


SELECT
    a.industry,
    COUNT(DISTINCT a.account_id)            AS total_accounts,
    COUNT(DISTINCT ce.account_id)           AS churned_accounts,
    ROUND(
        COUNT(DISTINCT ce.account_id) * 100.0 /
        NULLIF(COUNT(DISTINCT a.account_id), 0), 2
    )                                        AS churn_rate_pct
FROM   accounts a
LEFT   JOIN churn_events ce ON a.account_id = ce.account_id
GROUP  BY a.industry
ORDER  BY churn_rate_pct DESC;


SELECT
    ce.churn_event_id,
    ce.account_id,
    ce.churn_date,
    ce.reason_code,
    ce.preceding_downgrade_flag,
    ce.preceding_upgrade_flag,
    s.plan_tier                              AS last_plan,
    s.mrr_amount                             AS mrr_lost,
    (
        SELECT COUNT(*)
        FROM   support_tickets st
        WHERE  st.account_id = ce.account_id
          AND  st.submitted_at::date BETWEEN ce.churn_date - INTERVAL '90 days'
                                         AND  ce.churn_date
    )                                        AS support_tickets_last_90d
FROM   churn_events ce
LEFT   JOIN LATERAL (
    SELECT plan_tier, mrr_amount
    FROM   subscriptions sub
    WHERE  sub.account_id = ce.account_id
      AND  sub.churn_flag = TRUE
    ORDER  BY sub.end_date DESC
    LIMIT  1
) s ON TRUE
WHERE  ce.preceding_downgrade_flag = TRUE
ORDER  BY ce.churn_date DESC;


SELECT
    a.plan_tier,
    COUNT(*)                                          AS churned_accounts,
    ROUND(AVG(ce.churn_date - a.signup_date), 0)      AS avg_days_to_churn,
    MIN(ce.churn_date - a.signup_date)                AS min_days_to_churn,
    MAX(ce.churn_date - a.signup_date)                AS max_days_to_churn,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY ce.churn_date - a.signup_date
    )                                                  AS median_days_to_churn
FROM   churn_events ce
JOIN   accounts a ON ce.account_id = a.account_id
GROUP  BY a.plan_tier
ORDER  BY avg_days_to_churn;


WITH churned_mrr AS (
    SELECT
        DATE_TRUNC('month', ce.churn_date)::date AS month,
        ROUND(SUM(s.mrr_amount), 2)               AS mrr_churned
    FROM   churn_events ce
    JOIN   subscriptions s
        ON s.account_id = ce.account_id
        AND s.churn_flag = TRUE
    GROUP  BY DATE_TRUNC('month', ce.churn_date)
),
total_mrr AS (
    SELECT
        DATE_TRUNC('month', start_date)::date AS month,
        SUM(mrr_amount)                        AS mrr_total
    FROM   subscriptions
    WHERE  is_trial = FALSE AND mrr_amount > 0
    GROUP  BY DATE_TRUNC('month', start_date)
)
SELECT
    tm.month,
    ROUND(tm.mrr_total, 2)                 AS active_mrr,
    COALESCE(cm.mrr_churned, 0)            AS churned_mrr,
    ROUND(
        COALESCE(cm.mrr_churned, 0) * 100.0 /
        NULLIF(tm.mrr_total, 0), 2
    )                                       AS mrr_churn_rate_pct
FROM   total_mrr tm
LEFT   JOIN churned_mrr cm ON tm.month = cm.month
ORDER  BY tm.month;


SELECT
    ce.account_id,
    a.account_name,
    a.plan_tier,
    COUNT(*)                               AS churn_events,
    MIN(ce.churn_date)                     AS first_churn_date,
    MAX(ce.churn_date)                     AS last_churn_date,
    SUM(CASE WHEN ce.is_reactivation THEN 1 ELSE 0 END) AS reactivations,
    STRING_AGG(DISTINCT ce.reason_code, ', ')            AS churn_reasons
FROM   churn_events ce
JOIN   accounts a ON ce.account_id = a.account_id
GROUP  BY ce.account_id, a.account_name, a.plan_tier
HAVING COUNT(*) > 1
ORDER  BY churn_events DESC;
