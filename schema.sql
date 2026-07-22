-- ============================================================
--  PROJECT: Commodities Market Intelligence Platform
--  Author : Samer Zeeshan  |  github.com/samerzee09
--  Tools  : MySQL 8.0 / PostgreSQL 15
-- ============================================================

CREATE TABLE commodities (
    commodity_id    INT             PRIMARY KEY AUTO_INCREMENT,
    symbol          VARCHAR(10)     NOT NULL UNIQUE,
    name            VARCHAR(80)     NOT NULL,
    category        VARCHAR(30),    -- Energy, Metals, Agriculture, Livestock
    unit            VARCHAR(20),    -- Barrel, Troy Oz, Bushel, Pound
    exchange        VARCHAR(20)     -- NYMEX, COMEX, CBOT, ICE
);

CREATE TABLE price_history (
    price_id        INT             PRIMARY KEY AUTO_INCREMENT,
    commodity_id    INT             NOT NULL,
    trade_date      DATE            NOT NULL,
    open_price      DECIMAL(12,4)   NOT NULL,
    high_price      DECIMAL(12,4),
    low_price       DECIMAL(12,4),
    close_price     DECIMAL(12,4)   NOT NULL,
    settlement      DECIMAL(12,4),
    volume          BIGINT,
    open_interest   BIGINT,
    FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id),
    UNIQUE KEY uq_price (commodity_id, trade_date)
);

CREATE TABLE brokers (
    broker_id       INT             PRIMARY KEY AUTO_INCREMENT,
    broker_name     VARCHAR(100)    NOT NULL,
    firm_type       VARCHAR(30),    -- Institutional, Retail, Proprietary
    region          VARCHAR(30),
    license_no      VARCHAR(30)
);

CREATE TABLE transactions (
    tx_id           INT             PRIMARY KEY AUTO_INCREMENT,
    broker_id       INT             NOT NULL,
    commodity_id    INT             NOT NULL,
    trade_date      DATE            NOT NULL,
    direction       CHAR(1)         NOT NULL,  -- B=Buy, S=Sell
    quantity        DECIMAL(14,2)   NOT NULL,
    exec_price      DECIMAL(12,4)   NOT NULL,
    commission      DECIMAL(10,2),
    pnl             DECIMAL(12,2),
    strategy        VARCHAR(30),    -- Spot, Futures, Options, Hedge
    FOREIGN KEY (broker_id)    REFERENCES brokers(broker_id),
    FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id)
);

CREATE INDEX idx_price_date       ON price_history(trade_date);
CREATE INDEX idx_price_commodity  ON price_history(commodity_id);
CREATE INDEX idx_tx_date          ON transactions(trade_date);
CREATE INDEX idx_tx_broker        ON transactions(broker_id);
