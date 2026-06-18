SELECT
    feature_name,
    COUNT(DISTINCT subscription_id)             AS unique_subscriptions_used,
    COUNT(*)                                    AS total_usage_events,
    ROUND(SUM(usage_count), 0)                  AS total_usage_count,
    ROUND(AVG(usage_count), 2)                  AS avg_usage_per_event,
    ROUND(AVG(usage_duration_secs), 0)          AS avg_duration_secs,
    ROUND(AVG(usage_duration_secs) / 60.0, 1)  AS avg_duration_mins,
    SUM(error_count)                            AS total_errors,
    ROUND(SUM(error_count) * 100.0 /
          NULLIF(SUM(usage_count), 0), 2)       AS error_rate_pct,
    is_beta_feature
FROM   feature_usage
GROUP  BY feature_name, is_beta_feature
ORDER  BY unique_subscriptions_used DESC;


WITH active_subs AS (
    SELECT COUNT(DISTINCT subscription_id) AS total_active
    FROM   subscriptions
    WHERE  churn_flag = FALSE AND is_trial = FALSE
)
SELECT
    fu.feature_name,
    fu.is_beta_feature,
    COUNT(DISTINCT fu.subscription_id)            AS adopters,
    a.total_active                                AS total_active_subs,
    ROUND(COUNT(DISTINCT fu.subscription_id) * 100.0 /
          NULLIF(a.total_active, 0), 1)           AS adoption_rate_pct
FROM   feature_usage fu
CROSS  JOIN active_subs a
WHERE  fu.subscription_id IN (
    SELECT subscription_id FROM subscriptions WHERE churn_flag = FALSE AND is_trial = FALSE
)
GROUP  BY fu.feature_name, fu.is_beta_feature, a.total_active
ORDER  BY adoption_rate_pct DESC;


SELECT
    DATE_TRUNC('month', usage_date)::date  AS month,
    feature_name,
    COUNT(*)                               AS usage_events,
    COUNT(DISTINCT subscription_id)        AS unique_subs,
    SUM(usage_count)                       AS total_count,
    ROUND(AVG(usage_duration_secs), 0)     AS avg_duration_secs,
    SUM(error_count)                       AS errors
FROM   feature_usage
GROUP  BY DATE_TRUNC('month', usage_date), feature_name
ORDER  BY month, feature_name;


SELECT
    s.plan_tier,
    fu.feature_name,
    COUNT(*)                                AS usage_events,
    COUNT(DISTINCT fu.subscription_id)      AS unique_subs,
    ROUND(AVG(fu.usage_count), 2)           AS avg_usage_count,
    ROW_NUMBER() OVER (
        PARTITION BY s.plan_tier
        ORDER BY COUNT(*) DESC
    )                                        AS rank_within_tier
FROM   feature_usage fu
JOIN   subscriptions  s ON fu.subscription_id = s.subscription_id
GROUP  BY s.plan_tier, fu.feature_name
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY s.plan_tier
    ORDER BY COUNT(*) DESC
) <= 10
ORDER  BY s.plan_tier, rank_within_tier;



SELECT
    is_beta_feature,
    COUNT(DISTINCT feature_name)             AS distinct_features,
    COUNT(DISTINCT subscription_id)          AS unique_subscribers,
    COUNT(*)                                 AS total_events,
    ROUND(AVG(usage_count), 2)               AS avg_usage_per_event,
    ROUND(AVG(usage_duration_secs), 0)       AS avg_duration_secs,
    ROUND(SUM(error_count) * 100.0 /
          NULLIF(SUM(usage_count), 0), 2)    AS error_rate_pct
FROM   feature_usage
GROUP  BY is_beta_feature;


SELECT
    feature_name,
    is_beta_feature,
    SUM(usage_count)                          AS total_uses,
    SUM(error_count)                          AS total_errors,
    ROUND(SUM(error_count) * 100.0 /
          NULLIF(SUM(usage_count), 0), 2)     AS error_rate_pct,
    ROUND(AVG(usage_duration_secs), 0)        AS avg_duration_secs
FROM   feature_usage
GROUP  BY feature_name, is_beta_feature
ORDER  BY error_rate_pct DESC
LIMIT  15;


SELECT
    a.referral_source,
    fu.feature_name,
    COUNT(DISTINCT fu.subscription_id)        AS unique_subs,
    ROUND(AVG(fu.usage_count), 2)             AS avg_usage
FROM   feature_usage fu
JOIN   subscriptions  s ON fu.subscription_id = s.subscription_id
JOIN   accounts       a ON s.account_id = a.account_id
GROUP  BY a.referral_source, fu.feature_name
ORDER  BY a.referral_source, avg_usage DESC;


WITH sub_usage AS (
    SELECT
        subscription_id,
        COUNT(*)           AS events,
        SUM(usage_count)   AS total_count,
        SUM(usage_duration_secs) AS total_duration_secs,
        COUNT(DISTINCT feature_name) AS distinct_features_used
    FROM   feature_usage
    GROUP  BY subscription_id
),
percentiles AS (
    SELECT PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_count) AS p90_count
    FROM   sub_usage
)
SELECT
    su.subscription_id,
    s.account_id,
    a.account_name,
    s.plan_tier,
    su.events,
    su.total_count,
    su.distinct_features_used,
    ROUND(su.total_duration_secs / 3600.0, 1) AS total_usage_hrs
FROM   sub_usage su
JOIN   subscriptions s ON su.subscription_id = s.subscription_id
JOIN   accounts      a ON s.account_id = a.account_id
CROSS  JOIN percentiles p
WHERE  su.total_count >= p.p90_count
ORDER  BY su.total_count DESC
LIMIT  30;


SELECT
    usage_date,
    COUNT(DISTINCT subscription_id) AS daily_active_subs,
    SUM(usage_count)                AS daily_usage_count,
    COUNT(DISTINCT feature_name)    AS features_used
FROM   feature_usage
WHERE  usage_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP  BY usage_date
ORDER  BY usage_date;
