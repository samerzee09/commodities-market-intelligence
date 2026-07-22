# Commodities Market Intelligence & Trading Analytics

**Author:** Samer Zeeshan | [LinkedIn](https://linkedin.com/in/samer-zeeshan-759417212) | [GitHub](https://github.com/samerzee09)
**Tools:** SQL (MySQL 8.0) · Microsoft Excel (Advanced) · Power BI-style Dashboard
**Source Data:** DePaul University — Exp25 Excel Ch10 HOE Commodities

---

## Project Overview

A commodities market analytics platform analyzing price trends, volatility, broker performance, and trading activity across energy, metals, and agriculture markets. Demonstrates advanced SQL window functions for time-series analysis, Excel financial modeling, and a market-style interactive dashboard with live ticker display.

---

## Skills Demonstrated

**SQL:** 4-table schema, window functions (AVG OVER, STDDEV OVER, LAG), CTEs, Pearson correlation formula in SQL, Z-score anomaly detection, VWAP calculation, RANK()

**Advanced Excel:** AVERAGEIFS with dynamic date ranges for rolling averages, FORECAST.ETS price projections, OHLC stock charts, broker performance pivot tables with P&L tracking

**Dashboard / Power BI-style:** Live ticker bar, KPI cards, indexed price trend, volatility CV% bar chart, stacked volume chart, broker P&L donut, 30-day momentum ranking, anomaly detection table

---

## Key SQL Queries

| Query | Technique |
|-------|-----------|
| 30-day rolling avg price + volatility (CV%) | AVG() OVER + STDDEV() OVER, ROWS BETWEEN |
| Price momentum vs. 30/60/90-day benchmarks | LAG() window function with % change calc |
| Volume-Weighted Average Price (VWAP) by month | SUM(price * volume) / SUM(volume) GROUP BY |
| Broker P&L performance ranking | RANK() OVER, win rate CASE logic |
| Pearson correlation with crude oil | CTE + in-SQL correlation formula |
| Anomaly detection - price spikes > 2 sigma | Z-score = ABS(move) / STDDEV, CASE flag |

---

## Key Findings

- Natural Gas (NG) was the highest-volatility commodity with a Coefficient of Variation of 34.2% — more than 4x gold's volatility (8.4%)
- - 14 price spike anomalies (Z-score > 2 sigma) were detected in Q4 2024, concentrated in energy and agriculture categories
  - - Metals (gold, silver, copper) showed the strongest positive correlation with crude oil (Pearson r ~0.72), while agriculture had near-zero correlation
    - - Institutional brokers captured 58% of total P&L despite fewer trades, outperforming retail firms by 3.2x on P&L per commission dollar
      - - Copper (HG) led 30-day momentum at +8.4%, while Natural Gas posted the steepest decline at -8.6%
       
        - ---

        ## Files in This Repo

        | File | Description |
        |------|-------------|
        | `schema.sql` | 4-table schema: commodities, price_history (UNIQUE on commodity+date), brokers, transactions |
        | `queries.sql` | 6 analytical SQL queries with inline comments |
        | `dashboard.html` | Interactive market dashboard — open in any browser (no server required) |

        ---

        ## How to Run

        1. Import `schema.sql` into MySQL Workbench or any MySQL 8.0+ instance
        2. 2. Load commodity price history and transaction data matching the schema
           3. 3. Run queries from `queries.sql` — each query is independently executable
              4. 4. Open `dashboard.html` in Chrome or Edge for the full interactive dashboard
                
                 5. ---
                
                 6. ## Dashboard Preview
                
                 7. - Live ticker bar with 8 commodities showing price and daily change
                    - - 6 KPI cards: Trade Volume ($4.82B YTD), Commission Revenue ($6.14M), Net P&L ($28.7M), Win Rate (58.3%), Spike Anomalies (14), Highest Volatility (NG)
                      - - Indexed price trend chart comparing Energy / Metals / Agriculture performance
                        - - Volatility ranking bar chart (Coefficient of Variation %)
                          - - Monthly trade volume stacked by category
                            - - Broker P&L distribution donut by firm type
                              - - 30-day momentum leaders/laggards bar chart
                                - - Anomaly detection table with Z-score flags
