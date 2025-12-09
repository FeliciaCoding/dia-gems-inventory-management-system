CREATE SCHEMA if NOT EXISTS project;

SET
search_path TO project;

BEGIN;

--ENUM TYPE

CREATE TYPE code AS enum ('USD', 'HKD', 'CHF', 'EUR', 'NTD');
CREATE TYPE category AS enum ('Supplier', 'Client', 'Office', 'Lab', 'Manufacturer');
CREATE TYPE role AS enum ('Chief', 'Admin', 'Sales', 'Accountant');
CREATE TYPE shape AS enum ('Brilliant Cut', 'Pear Shape', 'Radiant Cut', 'Heart Shape', 'Emerald Cut', 'Baquette', 'Briolette', 'Kite', 'Marquise', 'Oval', 'Princess', 'Trillion');
CREATE TYPE clarity AS enum ('I1', 'I2', 'VS', 'VS1', 'VS2', 'VVS', 'VVS1', 'VVS2','FL', 'IF');
CREATE TYPE gem_type AS enum ('Sapphire', 'Emerald', 'Ruby', 'Diamond');
CREATE TYPE fancy_intensity AS enum ('Faint', 'Very Light', 'Light', 'Fancy light', 'Fancy','Fansy Vivid', 'Fancy intense', 'Fancy Deep', 'Fansy Dark');
CREATE TYPE fancy_color AS enum ('Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Violet', 'Gray');
CREATE TYPE jewelry_type AS enum ('Earrings', 'Necklace', 'Ring', 'Brooch', 'Bracelet');
CREATE TYPE metal_type AS enum ('PT900', 'PT950', '18k white gold', '14k white gold', '18k white/yellow gold', '18k rose gold', '18k white gold + PT');
CREATE TYPE update_type_enum AS enum ('Insert', 'Update', 'Delete');
CREATE TYPE action_role_type AS enum ('Creator', 'Approver', 'Processor', 'Reviewer');
CREATE TYPE lab_purpose AS enum ('Certify', 'Re-certify');
CREATE TYPE processing_type AS enum ('Remove oil', 'Recut');
CREATE TYPE payment_status AS enum ('Partial paid', 'Unpaid', 'Paid');
CREATE TYPE treatment AS enum ('No heat', 'heated', 'No oil', 'Minor Oil', 'Oiled');
CREATE TYPE gem_color AS enum ('Red', 'Blue', 'Green', 'Pigeon blood', 'Royal Blue');
CREATE TYPE white_scale AS enum ( 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
   'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');


--Create tables

CREATE TABLE currency
(
   code code PRIMARY KEY,
   name text NOT NULL UNIQUE
);


CREATE TABLE counterpart
(
   counterpart_id serial PRIMARY KEY,
   name           text UNIQUE                            NOT NULL,
   phone_number   text,
   address_short  text,
   city           text,
   postal_code    text,
   country        text,
   email          text UNIQUE,
   is_active      boolean                                NOT NULL DEFAULT TRUE,
   created_at     TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   updated_at     TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE account_type
(
   type_name   text PRIMARY KEY, -- Diamond supplier, jewellry supplier, retail client, diamond wholesaler, certification lab, NY office
   category    category NOT NULL,
   is_internal boolean  NOT NULL DEFAULT FALSE
);


CREATE TABLE counterpart_account_type
(
   counterpart_id INTEGER,
   type_name      text,
   PRIMARY KEY (counterpart_id, type_name),
   FOREIGN KEY (counterpart_id) REFERENCES counterpart (counterpart_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (type_name) REFERENCES account_type (type_name)
      ON DELETE CASCADE ON UPDATE CASCADE

);


CREATE TABLE employee
(
   employee_id    serial PRIMARY KEY,
   counterpart_id INTEGER                                NOT NULL,
   first_name     text                                   NOT NULL,
   last_name      text                                   NOT NULL,
   email          text UNIQUE                            NOT NULL,
   role           role                                   NOT NULL,
   is_active      boolean                                NOT NULL DEFAULT TRUE,
   created_at     TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   updated_at     TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   FOREIGN KEY (counterpart_id) REFERENCES counterpart (counterpart_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);

-- !! 8. move counterparties' keys from counterpart_action relation directly to the action
CREATE TABLE action
(
   action_id           serial PRIMARY KEY,
   from_counterpart_id INTEGER,
   to_counterpart_id   INTEGER,
   terms               text,
   remarks             text,
   created_at          TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   updated_at          TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   FOREIGN KEY (from_counterpart_id) REFERENCES counterpart (counterpart_id)
      ON DELETE SET NULL ON UPDATE CASCADE,
   FOREIGN KEY (to_counterpart_id) REFERENCES counterpart (counterpart_id)
      ON DELETE SET NULL ON UPDATE CASCADE,
   FOREIGN KEY (employee_id) REFERENCES employee (employee_id)
      ON DELETE SET NULL ON UPDATE CASCADE,
   CONSTRAINT valid_update_time CHECK (updated_at >= created_at),
   CONSTRAINT different_counterparts CHECK (
      from_counterpart_id IS NULL OR
      to_counterpart_id IS NULL OR
      from_counterpart_id != to_counterpart_id
)
   );


-- !! 6. update_log is maybe a weak entity with action as its strong entity
CREATE TABLE action_update_log
(
   log_sequence INTEGER                                NOT NULL,
   action_id    INTEGER                                NOT NULL,
   employee_id  INTEGER                                NOT NULL,
   update_type  update_type_enum                       NOT NULL,
   old_value    jsonb,
   new_value    jsonb,
   log_time     TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   PRIMARY KEY (action_id, log_sequence),
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (employee_id) REFERENCES employee (employee_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE item
(
   lot_id                serial PRIMARY KEY,
   stock_name            text                                   NOT NULL,
   purchase_date         TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   supplier_id           INTEGER                                NOT NULL,
   origin                text                                   NOT NULL,
   responsible_office_id INTEGER                                NOT NULL,
   created_at            TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   updated_at            TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   is_available          boolean                                NOT NULL DEFAULT TRUE,
   FOREIGN KEY (responsible_office_id) REFERENCES counterpart (counterpart_id)
      FOREIGN KEY (supplier_id) REFERENCES counterpart(counterpart_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
   CONSTRAINT valid_item_update CHECK (updated_at >= created_at)
);


CREATE TABLE action_item
(
   action_id     INTEGER,
   lot_id        INTEGER,
   quantity      INTEGER        NOT NULL,
   unit_price    DECIMAL(15, 2) NOT NULL,
   currency_code code           NOT NULL,
   PRIMARY KEY (action_id, lot_id),
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
   FOREIGN KEY (currency_code) REFERENCES currency (code)
      ON DELETE RESTRICT ON UPDATE CASCADE,
   CONSTRAINT positive_quantity CHECK (quantity > 0),
   CONSTRAINT non_negative_price CHECK (unit_price >= 0)
);


-- Actions tables
CREATE TABLE purchase
(
   action_id     INTEGER PRIMARY KEY,
   purchase_num  text UNIQUE,
   purchase_date DATE DEFAULT CURRENT_DATE,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE memo_in
(
   action_id            INTEGER PRIMARY KEY,
   memo_in_num          text NOT NULL UNIQUE,
   ship_date            DATE NOT NULL,
   expected_return_date DATE,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   CONSTRAINT valid_return_date CHECK (expected_return_date IS NULL OR expected_return_date >= ship_date)
);


CREATE TABLE return_memo_in
(
   action_id           INTEGER PRIMARY KEY,
   orig_memo_action_id INTEGER NOT NULL,
   return_memo_in_num  text UNIQUE,
   back_date           DATE    NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (orig_memo_action_id) REFERENCES memo_in (action_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE return_memo_in_items
(
   action_id INTEGER,
   lot_id    INTEGER,
   notes     text,
   PRIMARY KEY (action_id, lot_id),
   FOREIGN KEY (action_id) REFERENCES return_memo_in (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE memo_out
(
   action_id            INTEGER PRIMARY KEY,
   memo_out_num         text UNIQUE,
   ship_date            DATE NOT NULL,
   expected_return_date DATE,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   CONSTRAINT valid_return_date CHECK (expected_return_date IS NULL OR expected_return_date >= ship_date)
);


CREATE TABLE return_memo_out
(
   action_id           INTEGER PRIMARY KEY,
   orig_memo_action_id INTEGER NOT NULL,
   return_memo_out_num text UNIQUE,
   back_date           DATE    NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (orig_memo_action_id) REFERENCES memo_out (action_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE return_memo_out_items
(
   return_action_id INTEGER,
   lot_id           INTEGER,
   notes            text,
   PRIMARY KEY (return_action_id, lot_id),
   FOREIGN KEY (return_action_id) REFERENCES return_memo_out (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE transfer_to_office
(
   action_id    INTEGER PRIMARY KEY,
   transfer_num text UNIQUE,
   ship_date    DATE NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE transfer_to_lab
(
   action_id    INTEGER PRIMARY KEY,
   transfer_num text UNIQUE,
   ship_date    DATE        NOT NULL,
   lab_purpose  lab_purpose NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
);

-- back_from_lab(**action_id, back_from_lab_num**, back_date)
CREATE TABLE back_from_lab
(
   action_id         INTEGER PRIMARY KEY,
   orig_transfer_id  INTEGER NOT NULL,
   back_from_lab_num text UNIQUE,
   back_date         DATE    NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (orig_transfer_id) REFERENCES transfer_to_lab (action_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE back_from_lab_items
(
   action_id INTEGER,
   lot_id    INTEGER,
   notes     text,
   PRIMARY KEY (action_id, lot_id),
   FOREIGN KEY (action_id) REFERENCES back_from_lab (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE transfer_to_factory
(
   action_id       INTEGER PRIMARY KEY,
   transfer_num    text UNIQUE,
   ship_date       DATE NOT NULL,
   processing_type processing_type,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
);


CREATE TABLE back_from_factory
(
   action_id         INTEGER PRIMARY KEY,
   orig_transfer_id  INTEGER NOT NULL,
   back_from_fac_num text UNIQUE,
   back_date         DATE    NOT NULL,
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (orig_transfer_id) REFERENCES transfer_to_factory (action_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE back_from_factory_details
(
   action_id       INTEGER,
   lot_id          INTEGER,
   after_weight_ct DECIMAL(5, 2),
   after_shape     shape,
   after_length    DECIMAL(4, 2),
   after_width     DECIMAL(4, 2),
   after_depth     DECIMAL(4, 2),
   weight_loss_ct  DECIMAL(5, 2),
   note            text,
   PRIMARY KEY (action_id, lot_id),
   FOREIGN KEY (action_id) REFERENCES back_from_factory (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
   CONSTRAINT positive_after_measurements CHECK (
      (after_weight_ct IS NULL OR after_weight_ct > 0) AND
      (after_length IS NULL OR after_length > 0) AND
      (after_width IS NULL OR after_width > 0) AND
      (after_depth IS NULL OR after_depth > 0)
      )
);



CREATE TABLE sale
(
   action_id      INTEGER PRIMARY KEY,
   sale_num       text UNIQUE,
   sale_date      DATE           DEFAULT CURRENT_DATE,
   payment_method text,
   payment_status payment_status DEFAULT 'Unpaid',
   FOREIGN KEY (action_id) REFERENCES action (action_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);



-- loose_stone (**lot_id**, weight_ct, length, width, depth)
--    loose_stone.lot_id references item.lot_id

CREATE TABLE loose_stone
(
   lot_id    INTEGER PRIMARY KEY,
   weight_ct DECIMAL(5, 2) NOT NULL,
   shape     shape         NOT NULL,
   length    DECIMAL(4, 2) NOT NULL,
   width     DECIMAL(4, 2) NOT NULL,
   depth     DECIMAL(4, 2) NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
   CONSTRAINT positive_weight CHECK (weight_ct > 0),
   CONSTRAINT positive_dimensions CHECK (length > 0 AND width > 0 AND depth > 0)
);


-- white_diamond (**lot_id**, white_level, shape, clarity)
--     white_diamond.lot_id references loose_stone.lot_id

CREATE TABLE white_diamond
(
   lot_id      INTEGER PRIMARY KEY,
   white_scale white_scale NOT NULL,
   clarity     clarity     NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

-- colored_diamond (**lot_id**, gem_type, fancy_intensity, fancy_overton, fancy_color, shape, clarity)
--     colored_diamond.lot_id references loose_stone.lot_id


CREATE TABLE colored_diamond
(
   lot_id          INTEGER PRIMARY KEY,
   gem_type        gem_type        NOT NULL,
   fancy_intensity fancy_intensity NOT NULL,
   fancy_overtone  text            NOT NULL,
   fancy_color     fancy_color     NOT NULL,
   clarity         clarity         NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);

-- colored_gem_stone (**lot_id**, gem_type, shape, color, treatment, origin)
--     colored_gem_stone.lot_id references loose_stone.lot_id


CREATE TABLE colored_gem_stone
(
   lot_id    INTEGER PRIMARY KEY,
   gem_type  gem_type  NOT NULL,
   shape     shape     NOT NULL,
   gem_color gem_color NOT NULL,
   treatment treatment NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
      ON DELETE CASCADE ON UPDATE CASCADE
);

-- jewerly (**lot_id**, jew_type, gross_weight_gr, metal_type, metal_weight_gr,
--     total_center_stone_qty, total_center_stone_weight_ct, centered_stone_type,
--    total_side_stone_qty, total_side_stone_weight_ct, side_stone_type)
CREATE TABLE jewelry
(
   lot_id                       INTEGER PRIMARY KEY,
   jewelry_type                 jewelry_type  NOT NULL,
   gross_weight_gr              DECIMAL(5, 2) NOT NULL,
   metal_type                   metal_type    NOT NULL,
   metal_weight_gr              DECIMAL(5, 2) NOT NULL,
   total_center_stone_qty       INTEGER       NOT NULL,
   total_center_stone_weight_ct DECIMAL(5, 2) NOT NULL,
   centered_stone_type          text          NOT NULL,
   total_side_stone_qty         INTEGER       NOT NULL,
   total_side_stone_weight_ct   DECIMAL(5, 2) NOT NULL,
   side_stone_type              text          NOT NULL,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
   CONSTRAINT positive_weights CHECK (gross_weight_gr > 0 AND metal_weight_gr > 0),
   CONSTRAINT metal_weight_check CHECK (metal_weight_gr <= gross_weight_gr)

);

-- !! 9. certificate.item_id is missing
CREATE TABLE certificate
(
   certificate_id  serial PRIMARY KEY,
   lot_id          INTEGER,
   lab_id          INTEGER                                NOT NULL,
   certificate_num text                                   NOT NULL UNIQUE,
   issue_date      TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   shape           shape,
   weight_ct       DECIMAL(5, 2),
   length          DECIMAL(4, 2),
   width           DECIMAL(4, 2),
   depth           DECIMAL(4, 2),
   clarity         clarity,
   color           fancy_color,
   treatment       treatment,
   gem_type        gem_type,
   created_at      TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   updated_at      TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   FOREIGN KEY (lab_id) REFERENCES counterpart (counterpart_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
   FOREIGN KEY (lot_id) REFERENCES item (lot_id)
      ON DELETE SET NULL ON UPDATE CASCADE,
   CONSTRAINT valid_cert_update CHECK (updated_at >= created_at)
);


-- trigger
CREATE
OR REPLACE FUNCTION update_stone_after_factory()
RETURNS TRIGGER AS $$
BEGIN
UPDATE loose_stone
   SET weight_ct = COALESCE(new.after_weight_ct, weight_ct),
       shape     = COALESCE(new.after_shape, shape),
       length    = COALESCE(new.after_length, length),
       width     = COALESCE(new.after_width, width),
       depth     = COALESCE(new.after_depth, depth)
 WHERE lot_id = new.lot_id;
RETURN new;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_stone_measurements
   AFTER INSERT
   ON back_from_factory_details
   FOR EACH ROW
   EXECUTE function update_stone_after_factory();