SELECT 'accounts'       AS table_name, COUNT(*) AS row_count FROM accounts
UNION ALL
SELECT 'subscriptions',               COUNT(*)              FROM subscriptions
UNION ALL
SELECT 'feature_usage',               COUNT(*)              FROM feature_usage
UNION ALL
SELECT 'support_tickets',             COUNT(*)              FROM support_tickets
UNION ALL
SELECT 'churn_events',                COUNT(*)              FROM churn_events
ORDER BY table_name;


SELECT COUNT(*) AS orphan_subscriptions
FROM   subscriptions s
LEFT JOIN accounts a ON s.account_id = a.account_id
WHERE  a.account_id IS NULL;

SELECT COUNT(*) AS orphan_feature_usage
FROM   feature_usage fu
LEFT JOIN subscriptions s ON fu.subscription_id = s.subscription_id
WHERE  s.subscription_id IS NULL;

SELECT COUNT(*) AS orphan_support_tickets
FROM   support_tickets st
LEFT JOIN accounts a ON st.account_id = a.account_id
WHERE  a.account_id IS NULL;

SELECT COUNT(*) AS orphan_churn_events
FROM   churn_events ce
LEFT JOIN accounts a ON ce.account_id = a.account_id
WHERE  a.account_id IS NULL;
