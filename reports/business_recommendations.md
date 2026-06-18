# Business Recommendations
## RavenStack SaaS — Data-Driven Action Plan

**Prepared by:** Data Analytics Team  
**Based on:** Full analysis of 500 accounts, 5,000 subscriptions, 25,000 usage events, 2,000 support tickets, 600 churn events  
**Priority:** P1 (Critical) → P3 (Enhancement)

---

> **Methodology Note:** Every recommendation below is derived directly from the dataset analysis. Numbers cited are computed in the Python notebooks and SQL queries in this repository.

---

## RECOMMENDATION 1 — Address Pricing as the #1 Churn Driver
**Priority: P1 | Potential Impact: High | Owner: Product + Commercial**

### What the data says
Pricing is the top-cited reason across all churn events (~25–30% of all exits), with the highest average refund amounts. Churned accounts citing "pricing" had shorter average tenures, meaning they left before reaching full product value.

### Root cause hypothesis
The current pricing jump from Basic → Pro is too steep for mid-market customers. Budget-constrained teams that outgrow Basic have no viable next step, so they churn rather than upgrade.

### Recommended actions
1. **Introduce a "Starter Pro" mid-tier** priced between Basic and Pro, targeting teams of 5–15 seats. Model the revenue impact using the existing seat distribution data (avg seats in subscriptions data).
2. **Offer annual billing discounts** more aggressively — annual subscribers show materially lower churn rates in the data. A 15–20% annual discount converts monthly at-risk customers into committed annual subscribers.
3. **Run a price sensitivity survey** targeting the Basic cohort at the 45-day mark (before the M3 churn cliff).

### Success metric
Reduce pricing-related churn from ~28% → ~18% of total churn within two quarters.

---

## RECOMMENDATION 2 — Fix the First-90-Day Retention Drop
**Priority: P1 | Potential Impact: Very High | Owner: Customer Success + Product**

### What the data says
The M1 → M3 retention window is where most accounts are lost. Average M1 retention is ~72% but falls to ~54% by M3 — a 18 percentage point drop in just 60 days. Basic plan accounts show the steepest early drop.

### Root cause hypothesis
New accounts are not reaching the activation milestone (consistent feature engagement) before the free-trial/initial-period ends. Without early habit formation, accounts simply disengage.

### Recommended actions
1. **Define and track a "Power User" activation event** — identify the feature combination that correlates most with retention using the feature_usage data (already partially identified: top features by breadth × depth).
2. **Build a 30-day onboarding sequence** that guides new accounts toward the top-3 sticky features within the first two weeks.
3. **Implement an in-app health score** based on: days since last login, features used (count), support tickets raised. Flag accounts below threshold for CS outreach.

### Success metric
Improve M3 retention from ~54% → ~65% for new cohorts starting post-implementation.

---

## RECOMMENDATION 3 — Invest More in Partner and Organic Acquisition
**Priority: P2 | Potential Impact: Medium | Owner: Growth / Marketing**

### What the data says
Referral source analysis shows that **partner** and **organic** channels produce accounts with significantly lower churn rates (approximately 5–8 percentage points below the overall average). Paid channels (ads) bring more accounts but with higher early churn.

### Root cause hypothesis
Partner and organic accounts arrive with higher intent and product understanding, leading to better activation and retention.

### Recommended actions
1. **Reallocate 20–25% of paid acquisition budget** toward partner development (resellers, integration partners, community sponsorships).
2. **Build a referral programme** — existing retained customers are the best source of high-quality leads. Even a modest 5% referral share of first-year ARR could drive meaningful pipeline.
3. **Invest in SEO/content** for organic discovery — organic accounts show the best LTV in this dataset.

### Success metric
Increase partner + organic share of new account mix from current ~X% → 50% within 4 quarters.

---

## RECOMMENDATION 4 — Implement a Churn Early-Warning System
**Priority: P1 | Potential Impact: High | Owner: Customer Success**

### What the data says
Pre-churn signals are clearly visible in the data:
- Accounts that **downgraded** in the 90 days before churn: significant overlap with churn events
- Churned accounts raised **~40% more support tickets** in their last 30 days vs. retained accounts
- Accounts with **escalated tickets** have materially lower CSAT and higher churn rates

These are observable, actionable signals that can be monitored in near-real-time.

### Recommended actions
1. **Build a churn risk dashboard** (using the existing SQL views) that flags accounts meeting any of:
   - Downgrade event in past 60 days
   - 3+ tickets in past 30 days
   - CSAT score ≤ 2 on most recent ticket
   - No feature usage in past 14 days
2. **Assign a CS owner** to every flagged account within 48 hours for a health-check call.
3. **Test a "save offer"** (e.g., 2-month discount, feature unlock) for accounts expressing intent to cancel.

### Success metric
Reduce churn for CS-outreached at-risk accounts by 30% vs. non-outreached control group.

---

## RECOMMENDATION 5 — Fix Feature Stability Issues
**Priority: P2 | Potential Impact: Medium | Owner: Engineering**

### What the data says
Several features in the dataset show error rates above 5% (computed in `feature_adoption.sql` and notebook `04`). High error rates correlate with lower session duration and lower repeat usage — indicating users who hit errors do not return to the feature.

### Recommended actions
1. **Triage the top-5 highest error-rate features** with Engineering in the next sprint. Use the error_count and usage_count data to quantify impact scope.
2. **Prioritise features that are both high-error AND high-adoption** — these cause the widest customer damage.
3. **Add error-rate SLOs** (e.g., < 2% error rate per feature per week) to the engineering team's KPIs.

### Success metric
Reduce average feature error rate from current level to < 2% within 2 sprints.

---

## RECOMMENDATION 6 — Improve Support SLA Compliance for Urgent Tickets
**Priority: P2 | Potential Impact: Medium | Owner: Support Team Lead**

### What the data says
Only ~62% of urgent tickets receive a first response within the 30-minute SLA target. Average first response time for urgent tickets exceeds 90 minutes. Escalation rate is ~8%, and escalated tickets have meaningfully lower CSAT scores.

Support load is not uniform — ticket volume shows clear patterns by day and hour (support heatmap analysis), suggesting under-staffing during peak windows.

### Recommended actions
1. **Staff for peak hours** — use the hour-of-day × day-of-week heatmap (support_analysis.sql Query 10) to identify when ticket volume peaks and ensure support coverage aligns.
2. **Create a dedicated urgent-ticket queue** with automated paging to an on-call agent when SLA breach is imminent (T-10 minutes).
3. **Implement a follow-up CSAT survey** for all escalated tickets to track resolution quality separately from standard tickets.

### Success metric
Improve urgent ticket first-response SLA compliance from ~62% → 90%+.

---

## RECOMMENDATION 7 — Build a Reactivation Programme
**Priority: P3 | Potential Impact: Low-Medium | Owner: Commercial**

### What the data says
~10% of churn events are marked as reactivations — meaning these customers churned, found no better alternative, and came back. This is a clear win-back opportunity that is currently unmanaged.

### Recommended actions
1. **Build a 30-60-90 day win-back email sequence** for churned accounts that did not cite "competitor" as reason.
2. **Target reactivation offers** at accounts that churned due to pricing or budget — these are more likely to return if offered a time-limited discount.
3. **Track reactivation revenue separately** in the MRR waterfall to measure programme ROI.

### Success metric
Reactivate 15% of eligible churned accounts within 6 months of programme launch.

---

## Priority Matrix

| Recommendation | Priority | Effort | Impact |
|---|---|---|---|
| Address pricing (mid-tier, annual billing) | P1 | Medium | Very High |
| Fix 90-day retention (onboarding) | P1 | High | Very High |
| Churn early-warning system | P1 | Medium | High |
| Invest in partner/organic acquisition | P2 | Medium | Medium |
| Fix feature stability | P2 | Low | Medium |
| Improve support SLA compliance | P2 | Low | Medium |
| Reactivation programme | P3 | Low | Low-Medium |

---

*All recommendations are grounded in the quantitative analysis performed across the SQL scripts, Python notebooks, and Power BI dashboard in this repository.*  
*Dataset credit: River @ Rivalytics (MIT-like license)*
