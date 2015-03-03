-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS product;
-- DROP TABLE IF EXISTS invoice;

CREATE TABLE employee (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
email TEXT NOT NULL
);

CREATE TABLE customer (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
account_num VARCHAR(255) NOT NULL
);

CREATE TABLE product (
id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL
);

CREATE TABLE sales_head (
id SERIAL PRIMARY KEY,  
invoice_no INT NOT NULL,
invoice_date VARCHAR(255) NOT NULL,
invoice_freq VARCHAR(255) NOT NULL,
employee_id VARCHAR(255) NOT NULL,
customer_id VARCHAR(255) NOT NULL,
FOREIGN KEY (employee_id) REFERENCES employee(id) NOT NULL,
FOREIGN KEY (customer_id) REFERENCES customer(id) NOT NULL 
);

CREATE TABLE sales_body (
id SERIAL PRIMARY KEY,
unit_sold INT NOT NULL,
sale_amount VARCHAR(255) NOT NULL,
product_id VARCHAR(255) NOT NULL,
invoice_id VARCHAR(255) NOT NULL,
invoice_date_id VARCHAR(255) NOT NULL,
FOREIGN KEY (product_id) REFERENCES product(id),
FOREIGN KEY (invoice_id) REFERENCES sales_head(invoice_no),
FOREIGN KEY (invoice_date_id) REFERENCES sales_head(invoice_date)
); 