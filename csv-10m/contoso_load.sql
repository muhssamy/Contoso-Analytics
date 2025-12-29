-- ============================================================================
-- Contoso Database - Complete PostgreSQL Load Script
-- Based on actual CSV analysis from csv-10m dataset
-- ============================================================================

-- Step 1: Connect to existing contoso database
-- This script assumes 'contoso' database already exists
-- If not, create it first: CREATE DATABASE contoso;
\c contoso

-- Step 2: Drop existing tables if they exist
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS orderrows CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS store CASCADE;
DROP TABLE IF EXISTS date CASCADE;
DROP TABLE IF EXISTS currencyexchange CASCADE;

-- ============================================================================
-- Step 3: Create Tables (in dependency order)
-- ============================================================================

-- Date Dimension Table
CREATE TABLE date (
    date DATE,
    datekey INTEGER PRIMARY KEY,
    year INTEGER,
    yearquarter VARCHAR(50),
    yearquarternumber INTEGER,
    quarter VARCHAR(10),
    yearmonth VARCHAR(50),
    yearmonthshort VARCHAR(50),
    yearmonthnumber INTEGER,
    month VARCHAR(20),
    monthshort VARCHAR(10),
    monthnumber INTEGER,
    dayofweek VARCHAR(20),
    dayofweekshort VARCHAR(10),
    dayofweeknumber INTEGER,
    workingday INTEGER,
    workingdaynumber INTEGER
);

-- Currency Exchange Table
CREATE TABLE currencyexchange (
    date DATE,
    fromcurrency VARCHAR(10),
    tocurrency VARCHAR(10),
    exchange DECIMAL(18,6),
    PRIMARY KEY (date, fromcurrency, tocurrency)
);

-- Store Dimension Table
CREATE TABLE store (
    storekey INTEGER PRIMARY KEY,
    storecode INTEGER,
    geoareakey INTEGER,
    countrycode VARCHAR(10),
    countryname VARCHAR(100),
    state VARCHAR(100),
    opendate DATE,
    closedate DATE,
    description VARCHAR(500),
    squaremeters INTEGER,
    status VARCHAR(50)
);

-- Product Dimension Table
CREATE TABLE product (
    productkey INTEGER PRIMARY KEY,
    productcode INTEGER,
    productname VARCHAR(500),
    manufacturer VARCHAR(255),
    brand VARCHAR(100),
    color VARCHAR(50),
    weightunit VARCHAR(50),
    weight DECIMAL(18,6),
    cost DECIMAL(18,6),
    price DECIMAL(18,6),
    categorykey INTEGER,
    categoryname VARCHAR(100),
    subcategorykey INTEGER,
    subcategoryname VARCHAR(100)
);

-- Customer Dimension Table
CREATE TABLE customer (
    customerkey INTEGER PRIMARY KEY,
    geoareakey INTEGER,
    startdt DATE,
    enddt DATE,
    continent VARCHAR(50),
    gender VARCHAR(20),
    title VARCHAR(20),
    givenname VARCHAR(100),
    middleinitial VARCHAR(10),
    surname VARCHAR(100),
    streetaddress VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    statefull VARCHAR(100),
    zipcode VARCHAR(20),
    country VARCHAR(10),
    countryfull VARCHAR(100),
    birthday DATE,
    age INTEGER,
    occupation VARCHAR(255),
    company VARCHAR(255),
    vehicle VARCHAR(255),
    latitude DECIMAL(18,8),
    longitude DECIMAL(18,8)
);

-- Orders Fact Table
CREATE TABLE orders (
    orderkey BIGINT PRIMARY KEY,
    customerkey INTEGER,
    storekey INTEGER,
    orderdate DATE,
    deliverydate DATE,
    currencycode VARCHAR(10)
);

-- Order Rows Fact Table
CREATE TABLE orderrows (
    orderkey BIGINT,
    linenumber INTEGER,
    productkey INTEGER,
    quantity INTEGER,
    unitprice DECIMAL(18,6),
    netprice DECIMAL(18,6),
    unitcost DECIMAL(18,6),
    PRIMARY KEY (orderkey, linenumber)
);

-- Sales Fact Table
CREATE TABLE sales (
    orderkey BIGINT,
    linenumber INTEGER,
    orderdate DATE,
    deliverydate DATE,
    customerkey INTEGER,
    storekey INTEGER,
    productkey INTEGER,
    quantity INTEGER,
    unitprice DECIMAL(18,6),
    netprice DECIMAL(18,6),
    unitcost DECIMAL(18,6),
    currencycode VARCHAR(10),
    exchangerate DECIMAL(18,6),
    PRIMARY KEY (orderkey, linenumber)
);

-- ============================================================================
-- Step 4: Load Data from CSV Files
-- ============================================================================

-- IMPORTANT: Update the path to match your directory
-- Use forward slashes (/) even on Windows
-- Example: 'date.csv'

\echo 'Loading date dimension...'
\COPY date FROM 'date.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\echo 'Loading currency exchange...'
\COPY currencyexchange FROM 'currencyexchange.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\echo 'Loading store dimension...'
\COPY store FROM 'store.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8', NULL '');

\echo 'Loading product dimension...'
\COPY product FROM 'product.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\echo 'Loading customer dimension (this may take a few minutes)...'
\COPY customer FROM 'customer.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\echo 'Loading orders fact table (this may take a few minutes)...'
\COPY orders FROM 'orders.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\echo 'Loading order rows fact table (this may take several minutes)...'
\COPY orderrows FROM 'orderrows.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\echo 'Loading sales fact table (this may take 5-10 minutes)...'
\COPY sales FROM 'sales.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- ============================================================================
-- Step 5: Create Indexes for Performance
-- ============================================================================

\echo 'Creating indexes...'

-- Date table indexes
CREATE INDEX idx_date_date ON date(date);
CREATE INDEX idx_date_year ON date(year);
CREATE INDEX idx_date_month ON date(monthnumber);

-- Sales table indexes
CREATE INDEX idx_sales_orderdate ON sales(orderdate);
CREATE INDEX idx_sales_customerkey ON sales(customerkey);
CREATE INDEX idx_sales_storekey ON sales(storekey);
CREATE INDEX idx_sales_productkey ON sales(productkey);
CREATE INDEX idx_sales_currencycode ON sales(currencycode);

-- Orders table indexes
CREATE INDEX idx_orders_orderdate ON orders(orderdate);
CREATE INDEX idx_orders_customerkey ON orders(customerkey);
CREATE INDEX idx_orders_storekey ON orders(storekey);

-- Order rows table indexes
CREATE INDEX idx_orderrows_orderkey ON orderrows(orderkey);
CREATE INDEX idx_orderrows_productkey ON orderrows(productkey);

-- Customer table indexes
CREATE INDEX idx_customer_geoareakey ON customer(geoareakey);
CREATE INDEX idx_customer_country ON customer(country);

-- Product table indexes
CREATE INDEX idx_product_categoryname ON product(categoryname);
CREATE INDEX idx_product_brand ON product(brand);

-- ============================================================================
-- Step 6: Add Foreign Key Constraints
-- ============================================================================

\echo 'Adding foreign key constraints...'

-- Sales foreign keys
ALTER TABLE sales ADD CONSTRAINT fk_sales_customer FOREIGN KEY (customerkey) REFERENCES customer(customerkey);
ALTER TABLE sales ADD CONSTRAINT fk_sales_store FOREIGN KEY (storekey) REFERENCES store(storekey);
ALTER TABLE sales ADD CONSTRAINT fk_sales_product FOREIGN KEY (productkey) REFERENCES product(productkey);

-- Orders foreign keys
ALTER TABLE orders ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customerkey) REFERENCES customer(customerkey);
ALTER TABLE orders ADD CONSTRAINT fk_orders_store FOREIGN KEY (storekey) REFERENCES store(storekey);

-- Order rows foreign keys
ALTER TABLE orderrows ADD CONSTRAINT fk_orderrows_order FOREIGN KEY (orderkey) REFERENCES orders(orderkey);
ALTER TABLE orderrows ADD CONSTRAINT fk_orderrows_product FOREIGN KEY (productkey) REFERENCES product(productkey);

-- ============================================================================
-- Step 7: Create Useful Views for Analysis
-- ============================================================================

\echo 'Creating analytical views...'

-- Sales with full details view
CREATE OR REPLACE VIEW v_sales_details AS
SELECT 
    s.orderkey,
    s.linenumber,
    s.orderdate,
    s.deliverydate,
    d.year,
    d.quarter,
    d.month,
    d.dayofweek,
    c.givenname || ' ' || c.surname AS customername,
    c.city AS customercity,
    c.state AS customerstate,
    c.country AS customercountry,
    st.description AS storename,
    st.state AS storestate,
    st.countryname AS storecountry,
    p.productname,
    p.brand,
    p.categoryname,
    p.subcategoryname,
    s.quantity,
    s.unitprice,
    s.netprice,
    s.unitcost,
    s.quantity * s.netprice AS totalsales,
    s.quantity * s.unitcost AS totalcost,
    (s.quantity * s.netprice) - (s.quantity * s.unitcost) AS grossprofit,
    s.currencycode,
    s.exchangerate
FROM sales s
JOIN date d ON CAST(TO_CHAR(s.orderdate, 'YYYYMMDD') AS INTEGER) = d.datekey
JOIN customer c ON s.customerkey = c.customerkey
JOIN store st ON s.storekey = st.storekey
JOIN product p ON s.productkey = p.productkey;

-- Monthly sales summary view
CREATE OR REPLACE VIEW v_monthly_sales_summary AS
SELECT 
    d.year,
    d.monthnumber,
    d.month,
    COUNT(DISTINCT s.orderkey) AS totalorders,
    SUM(s.quantity) AS totalunits,
    SUM(s.quantity * s.netprice) AS totalsales,
    SUM(s.quantity * s.unitcost) AS totalcost,
    SUM((s.quantity * s.netprice) - (s.quantity * s.unitcost)) AS grossprofit,
    AVG(s.quantity * s.netprice) AS avgsaleamount
FROM sales s
JOIN date d ON CAST(TO_CHAR(s.orderdate, 'YYYYMMDD') AS INTEGER) = d.datekey
GROUP BY d.year, d.monthnumber, d.month
ORDER BY d.year, d.monthnumber;

-- ============================================================================
-- Step 8: Verify Data Load
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo 'DATA LOAD VERIFICATION'
\echo '============================================================================'

SELECT 
    'date' as table_name, 
    COUNT(*) as row_count,
    pg_size_pretty(pg_total_relation_size('date')) as total_size
FROM date
UNION ALL
SELECT 'currencyexchange', COUNT(*), pg_size_pretty(pg_total_relation_size('currencyexchange')) FROM currencyexchange
UNION ALL
SELECT 'store', COUNT(*), pg_size_pretty(pg_total_relation_size('store')) FROM store
UNION ALL
SELECT 'product', COUNT(*), pg_size_pretty(pg_total_relation_size('product')) FROM product
UNION ALL
SELECT 'customer', COUNT(*), pg_size_pretty(pg_total_relation_size('customer')) FROM customer
UNION ALL
SELECT 'orders', COUNT(*), pg_size_pretty(pg_total_relation_size('orders')) FROM orders
UNION ALL
SELECT 'orderrows', COUNT(*), pg_size_pretty(pg_total_relation_size('orderrows')) FROM orderrows
UNION ALL
SELECT 'sales', COUNT(*), pg_size_pretty(pg_total_relation_size('sales')) FROM sales
ORDER BY 1;

\echo ''
\echo '============================================================================'
\echo 'SAMPLE QUERIES'
\echo '============================================================================'

-- Total sales by year
\echo ''
\echo 'Total Sales by Year:'
SELECT 
    d.year,
    COUNT(DISTINCT s.orderkey) AS orders,
    SUM(s.quantity * s.netprice)::NUMERIC(18,2) AS total_sales
FROM sales s
JOIN date d ON CAST(TO_CHAR(s.orderdate, 'YYYYMMDD') AS INTEGER) = d.datekey
GROUP BY d.year
ORDER BY d.year;

-- Top 10 products by sales
\echo ''
\echo 'Top 10 Products by Sales:'
SELECT 
    p.productname,
    p.categoryname,
    SUM(s.quantity)::INTEGER AS total_units_sold,
    SUM(s.quantity * s.netprice)::NUMERIC(18,2) AS total_sales
FROM sales s
JOIN product p ON s.productkey = p.productkey
GROUP BY p.productname, p.categoryname
ORDER BY total_sales DESC
LIMIT 10;

\echo ''
\echo '============================================================================'
\echo 'DATABASE SETUP COMPLETE!'
\echo '============================================================================'
\echo 'You can now connect this database to Power BI'
\echo ''
\echo 'Useful views created:'
\echo '  - v_sales_details (detailed sales with all dimensions)'
\echo '  - v_monthly_sales_summary (aggregated monthly metrics)'
\echo ''