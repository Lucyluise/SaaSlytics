

SELECT
    COUNT(*)                                          AS total_tickets,
    COUNT(CASE WHEN closed_at IS NOT NULL THEN 1 END) AS resolved_tickets,
    COUNT(CASE WHEN closed_at IS NULL     THEN 1 END) AS open_tickets,
    ROUND(AVG(resolution_time_hours), 2)              AS avg_resolution_hours,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY resolution_time_hours), 2)          AS median_resolution_hours,
    ROUND(AVG(first_response_time_minutes), 0)        AS avg_first_response_mins,
    ROUND(AVG(satisfaction_score), 2)                 AS avg_csat,
    COUNT(CASE WHEN escalation_flag THEN 1 END)       AS escalated_tickets,
    ROUND(COUNT(CASE WHEN escalation_flag THEN 1 END) * 100.0 /
          NULLIF(COUNT(*), 0), 2)                     AS escalation_rate_pct
FROM   support_tickets;


SELECT
    DATE_TRUNC('month', submitted_at)::date  AS month,
    COUNT(*)                                  AS tickets_opened,
    COUNT(CASE WHEN closed_at IS NOT NULL THEN 1 END) AS tickets_resolved,
    ROUND(AVG(resolution_time_hours), 2)      AS avg_resolution_hrs,
    ROUND(AVG(satisfaction_score), 2)         AS avg_csat,
    COUNT(CASE WHEN escalation_flag THEN 1 END) AS escalations
FROM   support_tickets
GROUP  BY DATE_TRUNC('month', submitted_at)
ORDER  BY month;


SELECT
    priority,
    COUNT(*)                                          AS ticket_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_tickets,
    ROUND(AVG(resolution_time_hours), 2)              AS avg_resolution_hrs,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY resolution_time_hours), 2)          AS median_resolution_hrs,
    ROUND(AVG(first_response_time_minutes), 0)        AS avg_first_response_mins,
    ROUND(AVG(satisfaction_score), 2)                 AS avg_csat,
    COUNT(CASE WHEN escalation_flag THEN 1 END)       AS escalations,
    ROUND(COUNT(CASE WHEN escalation_flag THEN 1 END) * 100.0 /
          NULLIF(COUNT(*), 0), 1)                     AS escalation_rate_pct
FROM   support_tickets
GROUP  BY priority
ORDER  BY CASE priority
            WHEN 'urgent' THEN 1
            WHEN 'high'   THEN 2
            WHEN 'medium' THEN 3
            WHEN 'low'    THEN 4
          END;


SELECT
    satisfaction_score,
    COUNT(*)                                          AS responses,
    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER (), 1)                   AS pct_of_responses
FROM   support_tickets
WHERE  satisfaction_score IS NOT NULL
GROUP  BY satisfaction_score
ORDER  BY satisfaction_score;


SELECT
    DATE_TRUNC('month', submitted_at)::date   AS month,
    COUNT(CASE WHEN satisfaction_score IS NOT NULL THEN 1 END) AS responses,
    COUNT(*)                                   AS tickets,
    ROUND(COUNT(CASE WHEN satisfaction_score IS NOT NULL THEN 1 END) * 100.0 /
          NULLIF(COUNT(*), 0), 1)              AS response_rate_pct,
    ROUND(AVG(satisfaction_score), 2)          AS avg_csat,
    ROUND(COUNT(CASE WHEN satisfaction_score >= 4 THEN 1 END) * 100.0 /
          NULLIF(COUNT(CASE WHEN satisfaction_score IS NOT NULL THEN 1 END), 0), 1) AS promoter_pct,
    ROUND(COUNT(CASE WHEN satisfaction_score <= 2 THEN 1 END) * 100.0 /
          NULLIF(COUNT(CASE WHEN satisfaction_score IS NOT NULL THEN 1 END), 0), 1) AS detractor_pct
FROM   support_tickets
GROUP  BY DATE_TRUNC('month', submitted_at)
ORDER  BY month;


SELECT
    a.account_id,
    a.account_name,
    a.plan_tier,
    a.industry,
    a.churn_flag,
    COUNT(st.ticket_id)                          AS total_tickets,
    ROUND(AVG(st.resolution_time_hours), 2)      AS avg_resolution_hrs,
    ROUND(AVG(st.satisfaction_score), 2)         AS avg_csat,
    COUNT(CASE WHEN st.escalation_flag THEN 1 END) AS escalations,
    COUNT(CASE WHEN st.priority = 'urgent' THEN 1 END) AS urgent_tickets
FROM   support_tickets st
JOIN   accounts a ON st.account_id = a.account_id
GROUP  BY a.account_id, a.account_name, a.plan_tier, a.industry, a.churn_flag
ORDER  BY total_tickets DESC
LIMIT  25;


WITH account_tickets AS (
    SELECT
        a.account_id,
        a.churn_flag,
        a.plan_tier,
        COUNT(st.ticket_id)                           AS ticket_count,
        ROUND(AVG(st.resolution_time_hours), 2)       AS avg_resolution_hrs,
        ROUND(AVG(st.satisfaction_score), 2)          AS avg_csat,
        COUNT(CASE WHEN st.escalation_flag THEN 1 END) AS escalations
    FROM   accounts a
    LEFT   JOIN support_tickets st ON a.account_id = st.account_id
    GROUP  BY a.account_id, a.churn_flag, a.plan_tier
)
SELECT
    churn_flag,
    COUNT(*)                                AS accounts,
    ROUND(AVG(ticket_count), 2)             AS avg_tickets,
    ROUND(AVG(avg_resolution_hrs), 2)       AS avg_resolution_hrs,
    ROUND(AVG(avg_csat), 2)                 AS avg_csat,
    ROUND(AVG(escalations), 2)              AS avg_escalations,
    ROUND(SUM(ticket_count)::numeric /
          NULLIF(COUNT(*), 0), 2)           AS tickets_per_account
FROM   account_tickets
GROUP  BY churn_flag
ORDER  BY churn_flag;


SELECT
    a.plan_tier,
    st.priority,
    COUNT(*)                                       AS total_tickets,
    COUNT(CASE WHEN st.escalation_flag THEN 1 END) AS escalated,
    ROUND(COUNT(CASE WHEN st.escalation_flag THEN 1 END) * 100.0 /
          NULLIF(COUNT(*), 0), 1)                  AS escalation_rate_pct,
    ROUND(AVG(CASE WHEN st.escalation_flag
          THEN st.resolution_time_hours END), 2)   AS avg_resolution_hrs_escalated
FROM   support_tickets st
JOIN   accounts a ON st.account_id = a.account_id
GROUP  BY a.plan_tier, st.priority
ORDER  BY escalation_rate_pct DESC;


SELECT
    priority,
    COUNT(*)                                                  AS tickets,
    ROUND(AVG(first_response_time_minutes), 0)                AS avg_first_response_mins,
    CASE priority
        WHEN 'urgent' THEN  30
        WHEN 'high'   THEN  60
        WHEN 'medium' THEN 240
        WHEN 'low'    THEN 1440
    END                                                        AS sla_threshold_mins,
    COUNT(CASE WHEN
        (priority = 'urgent' AND first_response_time_minutes <=  30) OR
        (priority = 'high'   AND first_response_time_minutes <=  60) OR
        (priority = 'medium' AND first_response_time_minutes <= 240) OR
        (priority = 'low'    AND first_response_time_minutes <= 1440)
    THEN 1 END)                                                AS within_sla,
    ROUND(COUNT(CASE WHEN
        (priority = 'urgent' AND first_response_time_minutes <=  30) OR
        (priority = 'high'   AND first_response_time_minutes <=  60) OR
        (priority = 'medium' AND first_response_time_minutes <= 240) OR
        (priority = 'low'    AND first_response_time_minutes <= 1440)
    THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1)             AS sla_compliance_pct
FROM   support_tickets
GROUP  BY priority
ORDER  BY CASE priority
            WHEN 'urgent' THEN 1 WHEN 'high' THEN 2
            WHEN 'medium' THEN 3 WHEN 'low'  THEN 4
          END;


SELECT
    EXTRACT(DOW  FROM submitted_at) AS day_of_week,    -
    EXTRACT(HOUR FROM submitted_at) AS hour_of_day,
    COUNT(*)                         AS ticket_count
FROM   support_tickets
WHERE  submitted_at IS NOT NULL
GROUP  BY EXTRACT(DOW FROM submitted_at),
          EXTRACT(HOUR FROM submitted_at)
ORDER  BY day_of_week, hour_of_day;
