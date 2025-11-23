CREATE SCHEMA IF NOT EXISTS project;

SET search_path TO project;

BEGIN;


CREATE TABLE currency
(
    code VARCHAR(5) PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);


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


CREATE TABLE account_type
(
    type_name   VARCHAR(30) PRIMARY KEY,
    category    VARCHAR(30) NOT NULL,
    is_internal BOOLEAN     NOT NULL DEFAULT FALSE
);


CREATE TABLE counterpart_account_type
(
    counterpart_id BIGINT,
    type_name      VARCHAR(30),
    PRIMARY KEY (counterpart_id, type_name),
    FOREIGN KEY (counterpart_id) REFERENCES counterpart (counterpart_id),
    FOREIGN KEY (type_name) REFERENCES account_type (type_name)

);


CREATE TABLE employee
(
    employee_id BIGINT PRIMARY KEY,
    first_name  VARCHAR(30)        NOT NULL,
    last_name   VARCHAR(30)        NOT NULL,
    email       VARCHAR(50) UNIQUE NOT NULL,
    role        VARCHAR(50),
    is_active   BOOLEAN            NOT NULL DEFAULT TRUE
);


CREATE TABLE action
(
    action_id     BIGINT PRIMARY KEY,
    terms         VARCHAR(50),
    remarks       TEXT,
    creation_date TIMESTAMP                              NOT NULL,
    last_update   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
        CHECK (last_update >= creation_date)
);


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



CREATE TABLE counterpart_action
(
    from_counterpart_id BIGINT,
    to_counterpart_id   BIGINT,
    action_id           BIGINT,
    PRIMARY KEY (from_counterpart_id, to_counterpart_id, action_id),
    FOREIGN KEY (from_counterpart_id) REFERENCES counterpart (counterpart_id),
    FOREIGN KEY (to_counterpart_id) REFERENCES counterpart (counterpart_id),
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE action_item
(
    action_id     BIGINT,
    lot_id        BIGINT,
    line_no       INTEGER        NOT NULL,
    qty           INTEGER        NOT NULL,
    unit_price    MONEY          NOT NULL,
    currency_code VARCHAR(5) NOT NULL,
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
    action_id    BIGINT PRIMARY KEY,
    purchase_num VARCHAR(30),
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE memo_in
(
    action_id   BIGINT PRIMARY KEY,
    memo_in_num VARCHAR(30) NOT NULL,
    ship_date   DATE        NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE return_memo_in
(
    action_id           BIGINT PRIMARY KEY,
    orig_memo_action_id BIGINT NOT NULL,
    return_memo_in_num  VARCHAR(30),
    back_date           DATE   NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id),
    FOREIGN KEY (orig_memo_action_id) REFERENCES memo_in (action_id)
);



CREATE TABLE return_memo_in_items
(
    action_id    BIGINT,
    lot_id       BIGINT,
    qty_returned INTEGER NOT NULL,
    PRIMARY KEY (action_id, lot_id),
    FOREIGN KEY (action_id) REFERENCES return_memo_in (action_id),
    FOREIGN KEY (lot_id) REFERENCES item (lot_id),
    CHECK (qty_returned > 0)
);


CREATE TABLE memo_out
(
    action_id    BIGINT PRIMARY KEY,
    memo_out_num VARCHAR(30),
    ship_date    DATE NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE return_memo_out
(
    action_id           BIGINT PRIMARY KEY,
    orig_memo_action_id BIGINT NOT NULL,
    return_memo_out_num VARCHAR(30),
    back_date           DATE   NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id),
    FOREIGN KEY (orig_memo_action_id) REFERENCES memo_out (action_id)
);


CREATE TABLE return_memo_out_items
(
    return_action_id BIGINT,
    lot_id           BIGINT NOT NULL,
    qty_returned     INTEGER    NOT NULL,
    PRIMARY KEY (return_action_id, lot_id),
    FOREIGN KEY (return_action_id) REFERENCES return_memo_out (action_id),
    FOREIGN KEY (lot_id) REFERENCES item (lot_id),
    CHECK (qty_returned > 0)
);


CREATE TABLE transfer_to_office
(
    action_id    BIGINT PRIMARY KEY,
    transfer_num VARCHAR(30),
    ship_date    DATE NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE transfer_to_lab
(
    action_id    BIGINT PRIMARY KEY,
    transfer_num VARCHAR(30),
    ship_date    DATE NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- back_from_lab(**action_id, back_from_lab_num**, back_date)
CREATE TABLE back_from_lab
(
    action_id         BIGINT PRIMARY KEY,
    orig_transfer_id  BIGINT NOT NULL,
    back_from_lab_num VARCHAR(30),
    back_date         DATE   NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id),
    FOREIGN KEY (orig_transfer_id) REFERENCES transfer_to_lab (action_id)
);


CREATE TABLE back_from_lab_items
(
    action_id    BIGINT,
    lot_id       INTEGER NOT NULL,
    qty_returned INTEGER NOT NULL CHECK (qty_returned > 0),
    PRIMARY KEY (action_id, lot_id),
    FOREIGN KEY (action_id) REFERENCES back_from_lab (action_id),
    FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);



CREATE TABLE transfer_to_factory
(
    action_id    BIGINT PRIMARY KEY,
    transfer_num VARCHAR(30),
    ship_date    DATE NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);


CREATE TABLE back_from_factory
(
    action_id         BIGINT PRIMARY KEY,
    orig_transfer_id  BIGINT NOT NULL,
    back_from_fac_num VARCHAR(30),
    back_date         DATE   NOT NULL,
    FOREIGN KEY (action_id) REFERENCES action (action_id),
    FOREIGN KEY (orig_transfer_id) REFERENCES transfer_to_factory (action_id)
);


CREATE TABLE back_from_factory_details
(
    action_id    BIGINT PRIMARY KEY,
    lot_id       INTEGER NOT NULL,
    qty_returned INTEGER NOT NULL CHECK (qty_returned > 0),
    FOREIGN KEY (action_id) REFERENCES back_from_factory (action_id),
    FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);

CREATE TABLE sale
(
    action_id    BIGINT PRIMARY KEY,
    sale_num VARCHAR(30),
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);


-- item (**lot_id**, stock_name,
--    purchase_date, supplier, sale_unit, cost_unit, 
--    origin)
CREATE TABLE item
(
    lot_id        BIGINT                                 PRIMARY KEY,
    stock_name    VARCHAR(50)                            NOT NULL,
    purchase_date TIMESTAMP                              NOT NULL,
    supplier      BIGINT                                 NOT NULL,
    origin        VARCHAR(50)                            NOT NULL,
    creation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_update   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL  CHECK (last_update >= creation_date),

    FOREIGN KEY (supplier) REFERENCES counterpart (counterpart_id)
);


-- loose_stone (**lot_id**, weight_ct, length, width, depth)
--    loose_stone.lot_id references item.lot_id
CREATE TABLE loose_stone 
(
    lot_id        BIGINT    PRIMARY KEY,
    weight_ct     INTEGER   NOT NULL CHECK (weight_ct > 0),
    length        INTEGER   NOT NULL CHECK (length > 0),
    width         INTEGER   NOT NULL CHECK (width > 0),
    depth         INTEGER   NOT NULL CHECK (depth > 0),
    FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);

-- white_diamond (**lot_id**, white_level, shape, clarity)
--     white_diamond.lot_id references loose_stone.lot_id
CREATE TABLE white_diamond
(
    lot_id        BIGINT      PRIMARY KEY,
    white_level   VARCHAR(50) NOT NULL,
    shape         VARCHAR(50) NOT NULL,
    clarity       VARCHAR(50) NOT NULL,
    FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
);

-- colored_diamond (**lot_id**, gem_type, fancy_intensity, fancy_overton, fancy_color, shape, clarity)
--     colored_diamond.lot_id references loose_stone.lot_id
CREATE TABLE colored_diamond
(
    lot_id          BIGINT      PRIMARY KEY,
    gem_type        VARCHAR(50) NOT NULL,
    fancy_intensity VARCHAR(50) NOT NULL,
    fancy_overton   VARCHAR(50) NOT NULL,
    fancy_color     VARCHAR(50) NOT NULL,
    shape           VARCHAR(50) NOT NULL,
    white_level     VARCHAR(50) NOT NULL,
    clarity         VARCHAR(50) NOT NULL,
    FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
);

-- colored_gem_stone (**lot_id**, gem_type, shape, color, treatment, origin)
--     colored_gem_stone.lot_id references loose_stone.lot_id
CREATE TABLE colored_gem_stone
(
    lot_id        BIGINT        PRIMARY KEY,
    gem_type      VARCHAR(50)   NOT NULL,
    shape         VARCHAR(50)   NOT NULL,
    color         VARCHAR(50)   NOT NULL,
    treatment     VARCHAR(50)   NOT NULL,
    FOREIGN KEY (lot_id) REFERENCES loose_stone (lot_id)
);

-- jewerly (**lot_id**, jew_type, gross_weight_gr, metal_type, metal_weight_gr,
--     total_center_stone_qty, total_center_stone_weight_ct, centered_stone_type,
--    total_side_stone_qty, total_side_stone_weight_ct, side_stone_type)
CREATE TABLE jewelry
(
    lot_id                      BIGINT        PRIMARY KEY,
    jewelry_type                VARCHAR(50)   NOT NULL,
    gross_weight_gr             INTEGER       NOT NULL CHECK (gross_weight_gr > 0),
    metal_type                  VARCHAR(50)   NOT NULL,
    metal_weight_gr             INTEGER       NOT NULL CHECK (metal_weight_gr > 0),
    total_side_stone_qty        INTEGER       NOT NULL CHECK (total_side_stone_qty > 0),
    total_side_stone_weight_cty INTEGER       NOT NULL CHECK (total_side_stone_weight_cty > 0),
    side_stone_type             VARCHAR(50)   NOT NUL,
    FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);

-- certificate(**certificate_id**, lab_id, issue_date, shape, weight_ct, length, width, depth, clarity, color, treatment, gem_type)
--     certificate.lab_id references counterpart.counterpart_id
CREATE TABLE certificate
(
    certificate_id  BIGINT       PRIMARY KEY,
    lab_id          BIGINT       NOT NULL,
    certificate_num VARCHAR(50)  NOT NULL,
    issue_date      TIMESTAMP    NOT NULL,
    shape           VARCHAR(50),
    weight_ct       INTEGER CHECK (weight_ct > 0),
    length          INTEGER CHECK (length > 0),
    width           INTEGER CHECK (widht > 0),
    depth           INTEGER CHECK (depth > 0),
    clarity         VARCHAR(50),
    color           VARCHAR(50),
    treatment       VARCHAR(50),
    gem_type        VARCHAR(50),
    creation_date   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_update     TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL CHECK (last_update >= creation_date),

    FOREIGN KEY (lab_id) REFERENCES counterpart (counterpart_id)
); 


