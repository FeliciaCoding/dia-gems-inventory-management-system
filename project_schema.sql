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
    PRIMARY KEY (from_counterpart_id, to_counterpart_id, action_id),
    FOREIGN KEY (from_counterpart_id) REFERENCES counterpart (counterpart_id),
    FOREIGN KEY (to_counterpart_id) REFERENCES counterpart (counterpart_id),
    FOREIGN KEY (action_id) REFERENCES action (action_id)
);

-- action_item(**action_id**, **lot_id**, line_no, qty, unit_price,currency_code)
CREATE TABLE action_item
(
    action_id     BIGINT     NOT NULL,
    line_no       INT        NOT NULL,
    lot_id        BIGINT     NOT NULL,
    qty           INT        NOT NULL,
    unit_price    INT        NOT NULL,
    currency_code VARCHAR(5) NOT NULL,
    PRIMARY KEY (action_id, lot_id),
    UNIQUE (action_id, line_no),
    FOREIGN KEY (action_id) REFERENCES action (action_id),
    FOREIGN KEY (lot_id) REFERENCES item (lot_id),
    FOREIGN KEY (currency_code) REFERENCES currency (code),
    CHECK (qty > 0),
    CHECK (unit_price >=0)

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
    return_action_id   BIGINT PRIMARY KEY,
    return_memo_in_num VARCHAR(30),
    return_line_no     INT    NOT NULL,
    memo_in_action_id  BIGINT NOT NULL,
    memo_in_line_no    INT    NOT NULL,
    qty_returned       INT    NOT NULL,
    PRIMARY KEY (return_action_id, return_memo_in_num, return_line_no),
    FOREIGN KEY (return_action_id, return_memo_in_num) REFERENCES return_memo_in (action_id, return_memo_in_num),
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
    return_action_id    BIGINT PRIMARY KEY,
    return_memo_out_num VARCHAR(30),
    return_line_no      INT    NOT NULL,
    memo_out_action_id  BIGINT NOT NULL,
    memo_out_line_no    INT    NOT NULL,
    qty_returned        INT    NOT NULL,
    PRIMARY KEY (return_action_id, return_memo_out_num, return_line_no),
    FOREIGN KEY (return_action_id, return_memo_out_num) REFERENCES return_memo_out (action_id, return_memo_out_num),
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


-- item (**lot_id**, stock_name,
--    purchase_date, supplier, sale_unit, cost_unit, 
--    origin, creation_date)
CREATE TABLE item
(
    lot_id        BIGINT                                 PRIMARY KEY,
    stock_name    VARCHAR(50)                            NOT NULL,
    purchase_date TIMESTAMP                              NOT NULL,
    supplier      BIGINT                                 NOT NULL,
    origin        VARCHAR(50)                            NOT NULL,
    creation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_update   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

    FOREIGN KEY (supplier) REFERENCES counterpart (counterpart_id)
);


-- loose_stone (**lot_id**, weight_ct, length, width, depth)
--    loose_stone.lot_id references item.lot_id
CREATE TABLE loose_stone 
(
    lot_id        BIGINT    PRIMARY KEY,
    weight_ct     INTEGER   NOT NULL,
    length        INTEGER   NOT NULL,
    width         INTEGER   NOT NULL,
    depth         INTEGER   NOT NULL,
    FOREIGN KEY (lot_id) REFERENCES item (lot_id)
);

-- white_diamond (**lot_id**, white_level, shape, clarity)
--     white_diamond.lot_id references loose_stone.lot_id
CREATE TABLE white_diamond
(
    lot_id        BIGINT      PRIMARY KEY,
    white_level   INTEGER     NOT NULL,
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
    shape         VARCHAR(50)   NOT NULL,
    white_level   INTEGER       NOT NULL,
    clarity       VARCHAR(50)   NOT NULL,
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
CREATE TABLE jewerly 
(
    lot_id                      BIGINT        PRIMARY KEY,
    jewerly_type                VARCHAR(50)   NOT NULL,
    gross_weight_gr             INTEGER       NOT NULL,
    metal_type                  VARCHAR(50)   NOT NULL,
    metal_weight_gr             INTEGER       NOT NULL,
    total_side_stone_qty        INTEGER       NOT NULL,
    total_side_stone_weight_cty INTEGER       NOT NULL,
    side_stone_type             VARCHAR(50)   NOT NULL,
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
    weight_ct       INTEGER,
    length          INTEGER,
    width           INTEGER,
    depth           INTEGER,
    clarity         VARCHAR(50),
    color           VARCHAR(50),
    treatment       VARCHAR(50),
    gem_type        VARCHAR(50),
    creation_date   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_update     TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

    FOREIGN KEY (lab_id) REFERENCES counterpart (counterpart_id)
); 


