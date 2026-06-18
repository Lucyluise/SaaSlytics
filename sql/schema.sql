
DROP TABLE IF EXISTS feature_usage    CASCADE;
DROP TABLE IF EXISTS support_tickets  CASCADE;
DROP TABLE IF EXISTS churn_events     CASCADE;
DROP TABLE IF EXISTS subscriptions    CASCADE;
DROP TABLE IF EXISTS accounts         CASCADE;

CREATE TABLE accounts (
    account_id       VARCHAR(20)  PRIMARY KEY,
    account_name     VARCHAR(100) NOT NULL,
    industry         VARCHAR(50),                   
    country          CHAR(2),                        
    signup_date      DATE         NOT NULL,
    referral_source  VARCHAR(30),                   
    plan_tier        VARCHAR(20),                  
    seats            SMALLINT,
    is_trial         BOOLEAN      DEFAULT FALSE,
    churn_flag       BOOLEAN      DEFAULT FALSE
);

COMMENT ON TABLE  accounts IS 'One row per customer account (company). Root entity.';
COMMENT ON COLUMN accounts.plan_tier     IS 'Plan tier at time of account creation.';
COMMENT ON COLUMN accounts.churn_flag    IS 'TRUE if the account has churned at any point.';

CREATE TABLE subscriptions (
    subscription_id    VARCHAR(20)  PRIMARY KEY,
    account_id         VARCHAR(20)  NOT NULL REFERENCES accounts(account_id),
    start_date         DATE         NOT NULL,
    end_date           DATE,                           
    plan_tier          VARCHAR(20),
    seats              SMALLINT,
    mrr_amount         NUMERIC(10,2),                  
    arr_amount         NUMERIC(10,2),                  
    is_trial           BOOLEAN      DEFAULT FALSE,
    upgrade_flag       BOOLEAN      DEFAULT FALSE,     
    downgrade_flag     BOOLEAN      DEFAULT FALSE,     
    churn_flag         BOOLEAN      DEFAULT FALSE,     
    billing_frequency  VARCHAR(10),                   
    auto_renew_flag    BOOLEAN      DEFAULT TRUE
);

COMMENT ON TABLE  subscriptions IS 'One row per billing period. An account may have multiple rows.';
COMMENT ON COLUMN subscriptions.mrr_amount IS 'Monthly Recurring Revenue in USD at time of billing.';
COMMENT ON COLUMN subscriptions.arr_amount IS 'Annual Recurring Revenue = MRR × 12.';

CREATE TABLE feature_usage (
    usage_id              VARCHAR(20)  PRIMARY KEY,
    subscription_id       VARCHAR(20)  NOT NULL REFERENCES subscriptions(subscription_id),
    usage_date            DATE         NOT NULL,
    feature_name          VARCHAR(50),
    usage_count           INTEGER,                     
    usage_duration_secs   INTEGER,                    
    error_count           INTEGER      DEFAULT 0,
    is_beta_feature       BOOLEAN      DEFAULT FALSE
);

COMMENT ON TABLE  feature_usage IS 'One row per feature-usage event per subscription.';
COMMENT ON COLUMN feature_usage.is_beta_feature IS 'TRUE if the feature was in beta (~10% of events).';

CREATE TABLE support_tickets (
    ticket_id                    VARCHAR(20)  PRIMARY KEY,
    account_id                   VARCHAR(20)  NOT NULL REFERENCES accounts(account_id),
    submitted_at                 TIMESTAMP,
    closed_at                    TIMESTAMP,
    resolution_time_hours        NUMERIC(6,2),
    priority                     VARCHAR(10),          
    first_response_time_minutes  INTEGER,
    satisfaction_score           SMALLINT,             
    escalation_flag              BOOLEAN      DEFAULT FALSE
);

COMMENT ON TABLE  support_tickets IS 'One row per support ticket raised by a customer.';
COMMENT ON COLUMN support_tickets.satisfaction_score IS 'CSAT score 1–5; NULL if customer did not respond.';

CREATE TABLE churn_events (
    churn_event_id            VARCHAR(20)  PRIMARY KEY,
    account_id                VARCHAR(20)  NOT NULL REFERENCES accounts(account_id),
    churn_date                DATE,
    reason_code               VARCHAR(30),             
    refund_amount_usd         NUMERIC(10,2) DEFAULT 0,
    preceding_upgrade_flag    BOOLEAN      DEFAULT FALSE,
    preceding_downgrade_flag  BOOLEAN      DEFAULT FALSE,
    is_reactivation           BOOLEAN      DEFAULT FALSE,
    feedback_text             TEXT
);

COMMENT ON TABLE  churn_events IS 'One row per churn event; accounts can churn multiple times.';
COMMENT ON COLUMN churn_events.is_reactivation IS 'TRUE if account had previously churned and reactivated.';

CREATE INDEX idx_subscriptions_account  ON subscriptions(account_id);
CREATE INDEX idx_subscriptions_plan     ON subscriptions(plan_tier);
CREATE INDEX idx_subscriptions_start    ON subscriptions(start_date);
CREATE INDEX idx_feature_usage_sub      ON feature_usage(subscription_id);
CREATE INDEX idx_feature_usage_date     ON feature_usage(usage_date);
CREATE INDEX idx_feature_usage_feature  ON feature_usage(feature_name);
CREATE INDEX idx_support_account        ON support_tickets(account_id);
CREATE INDEX idx_support_submitted      ON support_tickets(submitted_at);
CREATE INDEX idx_churn_account          ON churn_events(account_id);
CREATE INDEX idx_churn_date             ON churn_events(churn_date);
