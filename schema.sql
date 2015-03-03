-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
email VARCHAR(255) NOT NULL
);

CREATE TABLE customers (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
account_num VARCHAR(255) NOT NULL
);

CREATE TABLE products (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL
);

CREATE TABLE invoices (
id SERIAL PRIMARY KEY,
sale_date VARCHAR(20) NOT NULL,
sale_amount VARCHAR(20) NOT NULL,
units integer NOT NULL,
invoice_number integer NOT NULL,
frequency VARCHAR(50) NOT NULL,
customer_id integer REFERENCES customers(id) NOT NULL,
employee_id integer REFERENCES employees(id) NOT NULL,
product_id integer REFERENCES products(id) NOT NULL
); 