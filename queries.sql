-- ============================================================
--  COMMODITIES MARKET: Analytical SQL Queries
--  Author: Samer Zeeshan  |  github.com/samerzee09
-- ============================================================

-- Q1: 30-Day Rolling Average Price & Volatility
SELECT
    c.symbol, c.name, c.category, ph.trade_date, ph.close_price,
    ROUND(AVG(ph.close_price) OVER (
        PARTITION BY ph.commodity_id ORDER BY ph.trade_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 4)    AS rolling_30d_avg,
    ROUND(STDDEV(ph.close_price) OVER (
        PARTITION BY ph.commodity_id ORDER BY ph.trade_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 4)    AS rolling_30d_stddev,
    ROUND(STDDEV(ph.close_price) OVER (
        PARTITION BY ph.commodity_id ORDER BY ph.trade_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
      / NULLIF(AVG(ph.close_price) OVER (
        PARTITION BY ph.commodity_id ORDER BY ph.trade_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 0) * 100, 2) AS coeff_of_variation_pct
FROM price_history ph
JOIN commodities c ON ph.commodity_id = c.commodity_id
ORDER BY ph.trade_date DESC, c.category;


-- Q2: Price Momentum -- % Change vs. 30/60/90 Days Ago (LAG Window)
SELECT
    c.symbol, c.name,
    ph.close_price                                    AS current_price,
    LAG(ph.close_price, 30) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date) AS price_30d_ago,
    LAG(ph.close_price, 60) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date) AS price_60d_ago,
    LAG(ph.close_price, 90) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date) AS price_90d_ago,
    ROUND((ph.close_price - LAG(ph.close_price,30) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date))
        / NULLIF(LAG(ph.close_price,30) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date),0)*100,2) AS momentum_30d_pct,
    ROUND((ph.close_price - LAG(ph.close_price,90) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date))
        / NULLIF(LAG(ph.close_price,90) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date),0)*100,2) AS momentum_90d_pct
FROM price_history ph
JOIN commodities c ON ph.commodity_id = c.commodity_id
WHERE ph.trade_date = (SELECT MAX(trade_date) FROM price_history)
ORDER BY momentum_30d_pct DESC;


-- Q3: Volume-Weighted Average Price (VWAP) by Month
SELECT
    c.symbol, c.name, c.category,
    DATE_FORMAT(ph.trade_date, '%Y-%m')              AS month,
    SUM(ph.close_price * ph.volume) / NULLIF(SUM(ph.volume),0) AS vwap,
    SUM(ph.volume)                                   AS total_volume,
    MIN(ph.low_price)                                AS period_low,
    MAX(ph.high_price)                               AS period_high,
    MAX(ph.high_price) - MIN(ph.low_price)           AS price_range
FROM price_history ph
JOIN commodities c ON ph.commodity_id = c.commodity_id
GROUP BY c.symbol, c.name, c.category, DATE_FORMAT(ph.trade_date, '%Y-%m')
ORDER BY month DESC, total_volume DESC;


-- Q4: Broker Performance with RANK() Window Function
SELECT
    b.broker_name, b.firm_type, b.region,
    COUNT(t.tx_id)                                   AS total_trades,
    SUM(t.quantity * t.exec_price)                   AS gross_trade_value,
    SUM(t.commission)                                AS total_commission,
    SUM(t.pnl)                                       AS total_pnl,
    ROUND(SUM(t.pnl) / NULLIF(SUM(t.commission),0), 2) AS pnl_per_commission,
    SUM(CASE WHEN t.pnl > 0 THEN 1 ELSE 0 END)      AS winning_trades,
    ROUND(SUM(CASE WHEN t.pnl > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(t.tx_id), 1) AS win_rate_pct,
    RANK() OVER (ORDER BY SUM(t.pnl) DESC)           AS pnl_rank
FROM transactions t
JOIN brokers b ON t.broker_id = b.broker_id
GROUP BY b.broker_name, b.firm_type, b.region
ORDER BY total_pnl DESC;


-- Q5: Pearson Correlation of Each Category with Crude Oil (CTE)
WITH oil_prices AS (
    SELECT trade_date, close_price AS oil_close
    FROM price_history
    WHERE commodity_id = (SELECT commodity_id FROM commodities WHERE symbol = 'CL')
),
category_daily AS (
    SELECT c.category, ph.trade_date, AVG(ph.close_price) AS avg_close
    FROM price_history ph
    JOIN commodities c ON ph.commodity_id = c.commodity_id
    WHERE c.symbol != 'CL'
    GROUP BY c.category, ph.trade_date
)
SELECT
    cd.category,
    ROUND(
        (COUNT(*) * SUM(cd.avg_close * op.oil_close) - SUM(cd.avg_close) * SUM(op.oil_close))
        / SQRT(
            (COUNT(*) * SUM(cd.avg_close * cd.avg_close) - POW(SUM(cd.avg_close),2))
          * (COUNT(*) * SUM(op.oil_close * op.oil_close) - POW(SUM(op.oil_close),2))
        ), 3) AS pearson_correlation_with_crude
FROM category_daily cd
JOIN oil_prices op ON cd.trade_date = op.trade_date
GROUP BY cd.category
ORDER BY ABS(pearson_correlation_with_crude) DESC;


-- Q6: Anomaly Detection -- Price Spike Flags (Z-Score > 2 sigma)
WITH stats AS (
    SELECT commodity_id,
        AVG(close_price - LAG(close_price,1) OVER (PARTITION BY commodity_id ORDER BY trade_date)) AS avg_daily_move,
        STDDEV(close_price - LAG(close_price,1) OVER (PARTITION BY commodity_id ORDER BY trade_date)) AS stddev_daily_move
    FROM price_history
    GROUP BY commodity_id
)
SELECT
    c.symbol, c.name, ph.trade_date, ph.close_price,
    LAG(ph.close_price,1) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date) AS prev_close,
    ROUND(ph.close_price - LAG(ph.close_price,1) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date), 4) AS daily_move,
    ROUND(ABS(ph.close_price - LAG(ph.close_price,1) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date))
        / NULLIF(s.stddev_daily_move,0), 2) AS z_score,
    CASE WHEN ABS(ph.close_price - LAG(ph.close_price,1) OVER (PARTITION BY ph.commodity_id ORDER BY ph.trade_date))
        / NULLIF(s.stddev_daily_move,0) > 2 THEN 'SPIKE' ELSE 'Normal' END AS anomaly_flag
FROM price_history ph
JOIN commodities c ON ph.commodity_id = c.commodity_id
JOIN stats s ON ph.commodity_id = s.commodity_id
ORDER BY ABS(daily_move) DESC;
