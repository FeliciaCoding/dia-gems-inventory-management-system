CREATE SCHEMA IF NOT EXISTS project;

SET search_path TO project;

BEGIN;


CREATE TABLE currency
(
   code TEXT PRIMARY KEY,
   name TEXT NOT NULL
);


CREATE TABLE counterpart
(
   counterpart_id SERIAL PRIMARY KEY,
   name           TEXT UNIQUE NOT NULL,
   phone_number   TEXT,
   address_short  TEXT,
   city           TEXT,
   postal_code    TEXT,
   country        TEXT,
   email          TEXT UNIQUE
);


CREATE TABLE account_type
(
   type_name   TEXT PRIMARY KEY,
   category    TEXT    NOT NULL,
   is_internal BOOLEAN NOT NULL DEFAULT FALSE
);


CREATE TABLE counterpart_account_type
(
   counterpart_id SERIAL,
   type_name      TEXT,
   PRIMARY KEY (counterpart_id, type_name),
   FOREIGN KEY (counterpart_id) REFERENCES counterpart (counterpart_id),
   FOREIGN KEY (type_name) REFERENCES account_type (type_name)

);


CREATE TABLE employee
(
   employee_id SERIAL PRIMARY KEY,
   first_name  TEXT        NOT NULL,
   last_name   TEXT        NOT NULL,
   email       TEXT UNIQUE NOT NULL,
   role        TEXT,
   is_active   BOOLEAN     NOT NULL DEFAULT TRUE
);


CREATE TABLE action
(
   action_id     SERIAL PRIMARY KEY,
   terms         TEXT,
   remarks       TEXT,
   creation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
   last_update   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
      CHECK (last_update >= creation_date)
);


CREATE TABLE update_log
(
   log_id      SERIAL PRIMARY KEY,
   action_id   SERIAL                                 NOT NULL,
   employee_id SERIAL                                 NOT NULL,
   update_type TEXT                                   NOT NULL,
   log_time    TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id),
   FOREIGN KEY (employee_id) REFERENCES employee (employee_id)
);



CREATE TABLE counterpart_action
(
   from_counterpart_id SERIAL,
   to_counterpart_id   SERIAL,
   action_id           SERIAL,
   PRIMARY KEY (from_counterpart_id, to_counterpart_id, action_id),
   FOREIGN KEY (from_counterpart_id) REFERENCES counterpart (counterpart_id),
   FOREIGN KEY (to_counterpart_id) REFERENCES counterpart (counterpart_id),
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE action_item
(
   action_id     SERIAL,
   lot_id        SERIAL,
   line_no       INT  NOT NULL,
   qty           INT  NOT NULL,
   unit_price    INT  NOT NULL,
   currency_code TEXT NOT NULL,
   PRIMARY KEY (action_id, lot_id),
   UNIQUE (action_id, line_no),
   FOREIGN KEY (action_id) REFERENCES action (action_id),
   FOREIGN KEY (lot_id) REFERENCES item (lot_id),
   FOREIGN KEY (currency_code) REFERENCES currency (code),
   CHECK (qty > 0),
   CHECK (unit_price >= 0)

);


CREATE TABLE purchase
(
   action_id    SERIAL PRIMARY KEY,
   purchase_num TEXT,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE memo_in
(
   action_id   SERIAL PRIMARY KEY,
   memo_in_num TEXT NOT NULL,
   ship_date   DATE NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE return_memo_in
(
   action_id           SERIAL PRIMARY KEY,
   orig_memo_action_id SERIAL NOT NULL,
   return_memo_in_num  TEXT,
   back_date           DATE   NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id),
   FOREIGN KEY (orig_memo_action_id) REFERENCES memo_in (action_id)
);



CREATE TABLE return_memo_in_items
(
   action_id    SERIAL,
   lot_id       SERIAL,
   qty_returned INT NOT NULL,
   PRIMARY KEY (action_id, lot_id),
   FOREIGN KEY (action_id) REFERENCES return_memo_in (action_id),
   FOREIGN KEY (lot_id) REFERENCES item (lot_id),
   CHECK (qty_returned > 0)
);


CREATE TABLE memo_out
(
   action_id    SERIAL PRIMARY KEY,
   memo_out_num TEXT,
   ship_date    DATE NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE return_memo_out
(
   action_id           SERIAL PRIMARY KEY,
   orig_memo_action_id SERIAL NOT NULL,
   return_memo_out_num TEXT,
   back_date           DATE   NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id),
   FOREIGN KEY (orig_memo_action_id) REFERENCES memo_out (action_id)
);


CREATE TABLE return_memo_out_items
(
   return_action_id SERIAL,
   lot_id           SERIAL NOT NULL,
   qty_returned     INT    NOT NULL,
   PRIMARY KEY (return_action_id, lot_id),
   FOREIGN KEY (return_action_id) REFERENCES return_memo_out (action_id),
   FOREIGN KEY (lot_id) REFERENCES item (lot_id),
   CHECK (qty_returned > 0)
);


CREATE TABLE transfer_to_office
(
   action_id    SERIAL PRIMARY KEY,
   transfer_num TEXT,
   ship_date    DATE NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE transfer_to_lab
(
   action_id    SERIAL PRIMARY KEY,
   transfer_num TEXT,
   ship_date    DATE NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- back_from_lab(**action_id, back_from_lab_num**, back_date)
CREATE TABLE back_from_lab
(
   action_id         SERIAL PRIMARY KEY,
   orig_transfer_id  SERIAL NOT NULL,
   back_from_lab_num TEXT,
   back_date         DATE   NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id),
   FOREIGN KEY (orig_transfer_id) REFERENCES transfer_to_lab (action_id)
);


CREATE TABLE back_from_lab_items
(
   action_id    SERIAL,
   lot_id       SERIAL NOT NULL,
   qty_returned INT    NOT NULL,
   PRIMARY KEY (action_id, lot_id),
   FOREIGN KEY (action_id) REFERENCES back_from_lab (action_id),
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);



CREATE TABLE transfer_to_factory
(
   action_id    SERIAL PRIMARY KEY,
   transfer_num TEXT,
   ship_date    DATE NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE back_from_factory
(
   action_id         SERIAL PRIMARY KEY,
   orig_transfer_id  SERIAL NOT NULL,
   back_from_fac_num TEXT,
   back_date         DATE   NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id),
   FOREIGN KEY (orig_transfer_id) REFERENCES transfer_to_factory (action_id)
);


CREATE TABLE back_from_factory_details
(
   action_id    SERIAL PRIMARY KEY,
   lot_id       SERIAL NOT NULL,
   qty_returned INT    NOT NULL,
   FOREIGN KEY (action_id) REFERENCES back_from_factory (action_id),
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);

CREATE TABLE sale
(
   action_id SERIAL PRIMARY KEY,
   sale_num  TEXT,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
);



-- item (**lot_id**, stock_name,
--    purchase_date, supplier, sale_unit, cost_unit, 
--    origin)
CREATE TABLE item
(
   lot_id        SERIAL PRIMARY KEY,
   stock_name    TEXT                                   NOT NULL,
   purchase_date TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
   supplier      SERIAL                                 NOT NULL,
   origin        TEXT                                   NOT NULL,
   creation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
   last_update   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

   FOREIGN KEY (supplier) REFERENCES counterpart (counterpart_id)
);


-- loose_stone (**lot_id**, weight_ct, length, width, depth)
--    loose_stone.lot_id references item.lot_id
CREATE TABLE loose_stone
(
   lot_id    SERIAL PRIMARY KEY,
   weight_ct DECIMAL(10, 2) NOT NULL,
   length    DECIMAL(10, 2) NOT NULL,
   width     DECIMAL(10, 2) NOT NULL,
   depth     DECIMAL(10, 2) NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);

-- white_diamond (**lot_id**, white_level, shape, clarity)
--     white_diamond.lot_id references loose_stone.lot_id
CREATE TABLE white_diamond
(
   lot_id      SERIAL PRIMARY KEY,
   white_level INTEGER NOT NULL,
   shape       TEXT    NOT NULL,
   clarity     TEXT    NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
);

-- colored_diamond (**lot_id**, gem_type, fancy_intensity, fancy_overton, fancy_color, shape, clarity)
--     colored_diamond.lot_id references loose_stone.lot_id
CREATE TABLE colored_diamond
(
   lot_id          SERIAL PRIMARY KEY,
   gem_type        TEXT NOT NULL,
   fancy_intensity TEXT NOT NULL,
   fancy_overton   TEXT NOT NULL,
   fancy_color     TEXT NOT NULL,
   shape           TEXT NOT NULL,
   white_level     TEXT NOT NULL,
   clarity         TEXT NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
);

-- colored_gem_stone (**lot_id**, gem_type, shape, color, treatment, origin)
--     colored_gem_stone.lot_id references loose_stone.lot_id
CREATE TABLE colored_gem_stone
(
   lot_id    SERIAL PRIMARY KEY,
   gem_type  TEXT NOT NULL,
   shape     TEXT NOT NULL,
   color     TEXT NOT NULL,
   treatment TEXT NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
);

-- jewerly (**lot_id**, jew_type, gross_weight_gr, metal_type, metal_weight_gr,
--     total_center_stone_qty, total_center_stone_weight_ct, centered_stone_type,
--    total_side_stone_qty, total_side_stone_weight_ct, side_stone_type)
CREATE TABLE jewelry
(
   lot_id                     SERIAL PRIMARY KEY,
   jewelry_type               TEXT           NOT NULL,
   gross_weight_gr            DECIMAL(10, 2) NOT NULL,
   metal_type                 TEXT           NOT NULL,
   metal_weight_gr            DECIMAL(10, 2) NOT NULL,
   total_side_stone_qty       INTEGER        NOT NULL,
   total_side_stone_weight_ct DECIMAL(10, 2) NOT NULL,
   side_stone_type            TEXT           NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);

-- certificate(**certificate_id**, lab_id, issue_date, shape, weight_ct, length, width, depth, clarity, color, treatment, gem_type)
--     certificate.lab_id references counterpart.counterpart_id
CREATE TABLE certificate
(
   certificate_id  SERIAL PRIMARY KEY,
   lab_id          SERIAL                                 NOT NULL,
   certificate_num TEXT                                   NOT NULL,
   issue_date      TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
   shape           TEXT,
   weight_ct       DECIMAL(10, 2),
   length          DECIMAL(10, 2),
   width           DECIMAL(10, 2),
   depth           DECIMAL(10, 2),
   clarity         TEXT,
   color           TEXT,
   treatment       TEXT,
   gem_type        TEXT,
   creation_date   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
   last_update     TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

   FOREIGN KEY (lab_id) REFERENCES counterpart (counterpart_id)
); 


