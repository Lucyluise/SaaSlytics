# Executive Summary
## RavenStack SaaS — Startup Growth Analytics

**Prepared by:** Data Analytics Team  
**Dataset:** RavenStack Synthetic SaaS Dataset (River @ Rivalytics)  
**Period Covered:** July 2023 – December 2025  
**Report Type:** Portfolio Analytics Project

---

## Business Context

RavenStack is a stealth-mode B2B SaaS company delivering AI-driven team productivity tools. The platform was piloted with coding bootcamp graduates before a planned public launch. This report summarises the key findings from a full analytical review of subscription, churn, feature usage, and support data across 500 customer accounts.

---

## Key Performance Indicators

| Metric | Value |
|---|---|
| Total Customer Accounts | 500 |
| Active (Non-Churned) Accounts | ~380 |
| Gross Account Churn Rate | ~24% |
| Total Subscriptions (all-time) | 5,000 |
| Total Feature Usage Events | 25,000 |
| Total Support Tickets | 2,000 |
| Churn Events Recorded | 600 |
| Avg CSAT Score | ~3.4 / 5.0 |

> Note: Active account counts and MRR values are derived from analysis of the processed dataset. Exact figures are computed programmatically in `04_business_insights.ipynb`.

---

## Section 1: Customer Growth

RavenStack acquired 500 accounts across the pilot period. Growth was driven primarily through **organic** and **partner** channels. New account sign-ups showed a consistent upward trend through mid-2024 before plateauing, suggesting the pilot market is approaching saturation.

**Plan Tier Mix at Signup:**
- Basic plan accounts for the majority of signups (~45%)
- Pro accounts represent a strong mid-tier (~35%)
- Enterprise accounts are a smaller but highest-value segment (~20%)

**Key Observation:** Basic plan accounts have the highest gross churn rate, indicating that low-commitment entry-level users churn faster when they do not find immediate value.

---

## Section 2: Revenue (MRR & ARR)

Monthly Recurring Revenue grew steadily through the pilot. Enterprise and Pro plans contribute disproportionately to total MRR relative to their account count, confirming a classic SaaS revenue concentration pattern.

**Highlights:**
- Enterprise accounts generate the highest average MRR per subscription
- Annual billing (vs. monthly) correlates with lower churn, as committed customers tend to be more invested
- MoM MRR growth was positive for the majority of observed months, with occasional dips during high-churn periods

**MRR Churn Impact:** Subscriptions that ended due to churn represent a meaningful share of lost recurring revenue. Pricing-related churns carry the highest average MRR loss.

---

## Section 3: Churn Analysis

**Gross Churn Rate: ~24%** (calculated as churned accounts ÷ total accounts over the pilot period)

**Top Churn Reasons (by volume):**
1. **Pricing** — the single largest driver of exit; customers found the product too expensive relative to perceived value
2. **Budget** — external budget constraints, not product dissatisfaction
3. **Features** — missing or incomplete features that were expected at signup
4. **Support** — poor support experience contributed to a meaningful share of churn

**Pre-Churn Signals Identified:**
- Accounts with a downgrade event in the 90 days before churn are significantly more likely to leave
- Churned accounts raised **~40% more support tickets** on average than retained accounts in their final 30 days
- Escalated tickets strongly correlate with eventual churn

**Reactivations:** ~10% of churn events are reactivations (accounts that previously churned), indicating some product-market fit exists and win-back campaigns could be effective.

---

## Section 4: Cohort Retention

Monthly cohorts were tracked through 12 periods post-signup.

**Average Retention Rates:**
- Month 1: ~72%
- Month 3: ~54%
- Month 6: ~41%
- Month 12: ~28%

These numbers indicate a steep early drop-off — a typical pattern for SaaS startups without a structured onboarding programme. The M1 → M3 drop is the steepest, suggesting the first 90 days are the most critical retention window.

**Best-performing cohorts** are those acquired through partner and organic channels, which tend to have higher product intent at signup.

**Revenue cohort analysis (NRR)** shows that expansion from upgrades partially offsets raw account churn, but not fully — Net Revenue Retention sits below 100%, meaning the business is currently contracting on a cohort basis.

---

## Section 5: Feature Adoption

25,000 usage events were recorded across 40 product features. Adoption is highly concentrated:
- The **top 10 features** account for the majority of usage events
- **Beta features** (10% of feature pool) show lower error rates than expected, suggesting a stable beta testing process
- Several features have **error rates above 5%**, which is a product stability concern

**Deep-engagement features** (high session duration + high breadth) are the strongest retention anchors and should be highlighted in onboarding flows.

---

## Section 6: Support Performance

2,000 support tickets were analysed across the pilot period.

| Metric | Value |
|---|---|
| Avg Resolution Time | ~32 hours |
| Avg First Response | ~90 minutes |
| Avg CSAT Score | ~3.4 / 5 |
| Escalation Rate | ~8% |
| Urgent Tickets SLA Compliance | ~62% |

**Key Issue:** Urgent tickets are missing their first-response SLA target in ~38% of cases. CSAT scores for escalated tickets are significantly lower than non-escalated ones, pointing to a quality gap in complex issue resolution.

---

## Conclusion

RavenStack demonstrates genuine product-market traction with 500 accounts acquired and consistent MRR growth during the pilot. However, the ~24% gross churn rate is above the healthy SaaS benchmark of 5–10% annually, and the support performance metrics suggest service quality is a retention risk. The business has clear, addressable opportunities in pricing strategy, onboarding, and customer success — all detailed in the accompanying Business Recommendations report.

---

*This report was produced as part of a Data Analytics portfolio project. All data is synthetic.*  
*Dataset credit: River @ Rivalytics (MIT-like license)*
