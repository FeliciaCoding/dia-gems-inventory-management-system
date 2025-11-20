CREATE SCHEMA IF NOT EXISTS project;

SET search_path TO project;

BEGIN;

-- counterpart (**counterpart_id**, name, phone_number, address_short, city, postal_code, country, email)
CREATE TABLE counterpart (
   counterpart_id BIGINT PRIMARY KEY,
   name VARCHAR(30) UNIQUE NOT NULL,
   phone_number   VARCHAR(30),
   address_short VARCHAR(100),
   city VARCHAR(30),
   postal_code VARCHAR(10),
   country  VARCHAR(30),
   email VARCHAR(100) UNIQUE
);

-- account_type (**type_name**, category, is_internal)
CREATE TABLE account_type (
   type_name VARCHAR(30) PRIMARY KEY,
   category VARCHAR(30) NOT NULL,
   is_internal BOOLEAN NOT NULL DEFAULT FALSE
);

-- counterpart_account_type (**counterpart_id**, **type_id**)
CREATE TABLE counterpart_account_type (
   counterpart_id BIGINT NOT NULL,
   type_name VARCHAR(30) NOT NULL,
   PRIMARY KEY (counterpart_id, type_name),
   FOREIGN KEY (counterpart_id) REFERENCES counterpart(counterpart_id),
   FOREIGN KEY (type_name) REFERENCES account_type(type_name)

);

-- employee (**employee_id**, first_name, last_name, email, role, is_active)
CREATE TABLE employee (
   employee_id BIGINT PRIMARY KEY,
   first_name VARCHAR(30) NOT NULL,
   last_name VARCHAR(30) NOT NULL,
   email VARCHAR(50) UNIQUE NOT NULL,
   role VARCHAR(50),
   is_active BOOLEAN NOT NULL DEFAULT TRUE,
)


-- action_log (**log_id**, action_id, employee_id, action_type, log_time)