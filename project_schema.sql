CREATE SCHEMA IF NOT EXISTS project;

SET search_path TO project;

BEGIN;

-- currency (**code**, name)
CREATE TABLE currency
(
   code VARCHAR(5) PRIMARY KEY,
   name VARCHAR(20) NOT NULL
);

-- counterpart (**counterpart_id**, name, phone_number, address_short, city, postal_code, country, email)
CREATE TABLE counterpart
(
   counterpart_id BIGINT PRIMARY KEY,
   name           VARCHAR(30) UNIQUE NOT NULL,
   phone_number   VARCHAR(30),
   address_short  VARCHAR(100),
   city           VARCHAR(30),
   postal_code    VARCHAR(10),
   country        VARCHAR(30),
   email          VARCHAR(100) UNIQUE
);

-- account_type (**type_name**, category, is_internal)
CREATE TABLE account_type
(
   type_name   VARCHAR(30) PRIMARY KEY,
   category    VARCHAR(30) NOT NULL,
   is_internal BOOLEAN     NOT NULL DEFAULT FALSE
);

-- counterpart_account_type (**counterpart_id**, **type_id**)
CREATE TABLE counterpart_account_type
(
   counterpart_id BIGINT      NOT NULL,
   type_name      VARCHAR(30) NOT NULL,
   PRIMARY KEY (counterpart_id, type_name),
   FOREIGN KEY (counterpart_id) REFERENCES counterpart (counterpart_id),
   FOREIGN KEY (type_name) REFERENCES account_type (type_name)

);

-- employee (**employee_id**, first_name, last_name, email, role, is_active)
CREATE TABLE employee
(
   employee_id BIGINT PRIMARY KEY,
   first_name  VARCHAR(30)        NOT NULL,
   last_name   VARCHAR(30)        NOT NULL,
   email       VARCHAR(50) UNIQUE NOT NULL,
   role        VARCHAR(50),
   is_active   BOOLEAN            NOT NULL DEFAULT TRUE
);

-- action (**action_id**, terms, remarks, creation_date, last_update)
CREATE TABLE action
(
   action_id     BIGINT PRIMARY KEY,
   terms         VARCHAR(50),
   remarks       TEXT,
   creation_date TIMESTAMP                              NOT NULL,
   last_update   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- update_log (**log_id**, action_id, employee_id, update_type, log_time)
CREATE TABLE update_log
(
   log_id      BIGINT PRIMARY KEY,
   action_id   BIGINT      NOT NULL,
   employee_id BIGINT      NOT NULL,
   update_type VARCHAR(30) NOT NULL,
   log_time    TIMESTAMP   NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id),
   FOREIGN KEY (employee_id) REFERENCES employee (employee_id)
);


-- counterpart_action (**from_counterpart_id, to_counterpart_id, action_id**)
CREATE TABLE counterpart_action
(
   from_counterpart_id BIGINT NOT NULL,
   to_counterpart_id   BIGINT NOT NULL,
   action_id           BIGINT NOT NULL,
   FOREIGN KEY (from_counterpart_id) REFERENCES counterpart (counterpart_id),
   FOREIGN KEY (to_counterpart_id) REFERENCES counterpart (counterpart_id),
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- action_item(**action_id**, **line_no**, lot_id, qty, unit_price,currency_code)
CREATE TABLE action_item
(
   action_id     BIGINT     NOT NULL,
   line_no       INT        NOT NULL,
   lot_id        BIGINT     NOT NULL,
   qty           INT        NOT NULL,
   unit_price    INT        NOT NULL,
   currency_code VARCHAR(5) NOT NULL,
   PRIMARY KEY (action_id, line_no),
   FOREIGN KEY (action_id) REFERENCES action (action_id),
   FOREIGN KEY (lot_id) REFERENCES item (lot_id),
   FOREIGN KEY (currency_code) REFERENCES currency (code)
);

-- purchase(**action_id**, purchase_num)
CREATE TABLE purchase
(
   action_id    BIGINT PRIMARY KEY,
   purchase_num VARCHAR(30),
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- memo_in (**action_id**, memo_in_num, ship_date)
CREATE TABLE memo_in
(
   action_id   BIGINT PRIMARY KEY,
   memo_in_num VARCHAR(30),
   ship_date   DATE,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- return_mem**o_in (**action_id, return_memo_in_num**, back_date)
CREATE TABLE return_memo_in
(
   action_id          BIGINT NOT NULL,
   return_memo_in_num VARCHAR(30),
   back_date          DATE   NOT NULL,
   PRIMARY KEY (action_id, return_memo_in_num),
   FOREIGN KEY (action_id) REFERENCES memo_in (action_id)
);


-- return_memo_in_details( **return_action_id, return_line_no**, memo_in_action_id, memo_in_line_no, qty_returned)
CREATE TABLE return_memo_in_details
(
   return_action_id  BIGINT PRIMARY KEY,
   return_line_no    INT    NOT NULL,
   memo_in_action_id BIGINT NOT NULL,
   memo_in_line_no   INT    NOT NULL,
   qty_returned      INT    NOT NULL,
   PRIMARY KEY (return_action_id, return_line_no),
   FOREIGN KEY (return_action_id) REFERENCES return_memo_in (action_id),
   FOREIGN KEY (memo_in_action_id) REFERENCES memo_in (action_id),
   FOREIGN KEY (memo_in_action_id, memo_in_line_no) REFERENCES action_item (action_id, line_no),
   CHECK (qty_returned > 0)
);

-- memo_out(**action_id**, memo_out_num, ship_date )
CREATE TABLE memo_out
(
   action_id    BIGINT PRIMARY KEY,
   memo_out_num VARCHAR(30),
   ship_date    DATE,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- return_memo_out(**action_id, return_memo_out_num**, back_date)
CREATE TABLE return_memo_out
(
   action_id           BIGINT NOT NULL,
   return_memo_out_num VARCHAR(30),
   back_date           DATE   NOT NULL,
   PRIMARY KEY (action_id, return_memo_out_num),
   FOREIGN KEY (action_id) REFERENCES memo_out (action_id)
);

-- return_memo_out_details( **return_action_id, return_line_no**, memo_out_action_id, memo_out_line_no, qty_returned)
CREATE TABLE return_memo_out_details
(
   return_action_id   BIGINT PRIMARY KEY,
   return_line_no     INT    NOT NULL,
   memo_out_action_id BIGINT NOT NULL,
   memo_out_line_no   INT    NOT NULL,
   qty_returned       INT    NOT NULL,
   PRIMARY KEY (return_action_id, return_line_no),
   FOREIGN KEY (return_action_id) REFERENCES return_memo_out (action_id),
   FOREIGN KEY (memo_out_action_id) REFERENCES memo_out (action_id),
   FOREIGN KEY (memo_out_action_id, memo_out_line_no) REFERENCES action_item (action_id, line_no)
);

-- transfer_to_office(**action_id**, transfer_num, ship_date)
CREATE TABLE transfer_to_office
(
   action_id    BIGINT PRIMARY KEY,
   transfer_num VARCHAR(30),
   ship_date    DATE,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- transfer_to_lab(**action_id**, transfer_num, ship_date)
CREATE TABLE transfer_to_lab
(
   action_id    BIGINT PRIMARY KEY,
   transfer_num VARCHAR(30),
   ship_date    DATE,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- back_from_lab(**action_id, back_from_lab_num**, back_date)
CREATE TABLE back_from_lab
(
   action_id         BIGINT NOT NULL,
   back_from_lab_num VARCHAR(30),
   back_date         DATE   NOT NULL,
   PRIMARY KEY (action_id, back_from_lab_num),
   FOREIGN KEY (action_id) REFERENCES transfer_to_lab (action_id)
);

-- back_from_lab_details(**return_action_id,return_line_no**, send_action_id, send_line_no, qty_returned)
CREATE TABLE back_from_lab_details
(
   return_action_id BIGINT PRIMARY KEY,
   return_line_no   INT    NOT NULL,
   send_action_id   BIGINT NOT NULL,
   send_line_no     INT    NOT NULL,
   qty_returned     INT    NOT NULL,
   PRIMARY KEY (return_action_id, return_line_no),
   FOREIGN KEY (return_action_id) REFERENCES back_from_lab (action_id),
   FOREIGN KEY (send_action_id) REFERENCES transfer_to_lab (action_id),
   FOREIGN KEY (send_action_id, send_line_no) REFERENCES action_item (action_id, line_no)
);
--CREATE TABLE transfer_to_factory();
--CREATE TABLE back_to_factory();
--CREATE TABLE back_from_factory_details();
--CREATE TABLE sale();


