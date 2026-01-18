SET search_path TO diamonds_are_forever;
BEGIN;

--Begin procedure # 1
-- Description:
-- Create a new purchase :
-- 1. Creates a new item (lot_id auto-generated)
-- 2. creates a purchase action,
-- 3. links the new lot to the purchase with price/currency.
-- DROP FUNCTION IF EXISTS diamonds_are_forever.pcd_create_purchase;
-- DROP PROCEDURE IF EXISTS diamonds_are_forever.pcd_create_purchase;
CREATE OR REPLACE PROCEDURE pcd_create_purchase(
    IN p_supplier_id           INT,
    IN p_office_id             INT,
    IN p_purchase_num          TEXT,
    IN p_stock_name            TEXT,
    IN p_origin                TEXT,
    IN p_item_type             diamonds_are_forever.item_category,
    IN p_price                 NUMERIC,
    IN p_currency_code         diamonds_are_forever.code,
    OUT v_lot_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action_id INT;
BEGIN
    -- Create the item (lot_id generated automatically)
    INSERT INTO diamonds_are_forever.item(
        stock_name,
        supplier_id,
        origin,
        responsible_office_id,
        item_type
    ) VALUES (
        p_stock_name,
        p_supplier_id,
        p_origin,
        p_office_id,
        p_item_type
    ) RETURNING lot_id INTO v_lot_id;

    -- Create action header for purchase (supplier -> office)
    INSERT INTO diamonds_are_forever.action(
        from_counterpart_id, to_counterpart_id,
        action_category, remarks
    )
    VALUES (
        p_supplier_id, p_office_id,
        'purchase', 'Purchase created via procedure'
    ) RETURNING action_id INTO v_action_id;

    -- specify the purchase
    INSERT INTO diamonds_are_forever.purchase(action_id, purchase_num)
    VALUES (v_action_id, p_purchase_num);

    -- Link item to action with price/currency
    INSERT INTO diamonds_are_forever.action_item(
        action_id, lot_id, price, currency_code)
    VALUES (v_action_id, v_lot_id, p_price, p_currency_code);
END;
$$;
-- END PROCEDURE #1


-- BEGIN PROCEDURE #2
-- Description:
-- Create new MEMO OUT:
-- 1 Insert into action with category = 'memo out', to_counterpart_id = client/partner receiving goods
-- 2 Insert into memo_out
-- 3 Insert into action_item with price + currency
-- 4 update availability
CREATE OR REPLACE PROCEDURE pcd_create_memo_out(
    office_id           INT,
    client_id           INT,
    in_memo_out_num     TEXT,
    in_ship_date        DATE,
    in_expected_return  DATE,
    in_lot_id           INT,
    memo_price          NUMERIC,
    in_currency_code    diamonds_are_forever.code
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action_id INT;
BEGIN
    INSERT INTO diamonds_are_forever.action(
        from_counterpart_id, to_counterpart_id, action_category, remarks)
    VALUES (
        office_id, client_id,
        'memo out', 'Memo out created via procedure'
    ) RETURNING action_id INTO v_action_id;

    INSERT INTO diamonds_are_forever.memo_out(
        action_id, memo_out_num, ship_date, expected_return_date)
    VALUES (v_action_id, in_memo_out_num,
        in_ship_date, in_expected_return);

    INSERT INTO diamonds_are_forever.action_item(
        action_id, lot_id, price, currency_code)
    VALUES (v_action_id, in_lot_id,
        memo_price, in_currency_code);

    -- update availability
    UPDATE diamonds_are_forever.item
    SET is_available = FALSE
    WHERE lot_id = in_lot_id;
END;
$$;
-- END PROCEDURE #2



-- BEGIN PROCEDURE #3
-- Create new sale :
-- 1 Creates a new action with action_category = 'sale' and links the sender office to the buyer
-- 2 Creates the sale document record in the sale table
-- 3 Links the sold lot to the sale action in action_item with its price and currency.
--
CREATE OR REPLACE PROCEDURE pcd_create_sale(
    office_id           INT,
    client_id           INT,
    in_sale_num         TEXT,
    in_payment_method   TEXT,
    in_payment_status   diamonds_are_forever.payment_status,
    in_lot_id           INT,
    final_sale_price    NUMERIC,
    in_currency_code    diamonds_are_forever.code
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action_id INT;
BEGIN
    INSERT INTO diamonds_are_forever.action(
        from_counterpart_id, to_counterpart_id, action_category, remarks)
    VALUES (office_id, client_id, 'sale', 'Sale created via procedure')
    RETURNING action_id INTO v_action_id;

    INSERT INTO diamonds_are_forever.sale(
        action_id, sale_num, payment_method, payment_status)
    VALUES (v_action_id, in_sale_num, in_payment_method, in_payment_status);

    INSERT INTO diamonds_are_forever.action_item(
        action_id, lot_id, price, currency_code)
    VALUES (v_action_id, in_lot_id, final_sale_price, in_currency_code);
END;
$$;
-- END PROCEDURE #3


-- BEGIN PROCEDURE #4
-- Description:
-- Transfer item to lab for certification
-- 1 Insert into action with category = 'transfer to lab'
-- 2 Insert into transfer_to_lab
-- 3 Insert into action_item
-- 4 Update item availability to FALSE
CREATE OR REPLACE PROCEDURE pcd_transfer_to_lab(
    p_office_id      INT,
    p_lab_id         INT,
    p_transfer_num   TEXT,
    p_ship_date      DATE,
    p_lab_purpose    diamonds_are_forever.lab_purpose,
    p_lot_id         INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action_id INT;
BEGIN
    INSERT INTO diamonds_are_forever.action(
        from_counterpart_id, to_counterpart_id, action_category, remarks)
    VALUES (p_office_id, p_lab_id, 'transfer to lab',
        'Item sent to lab for certification')
    RETURNING action_id INTO v_action_id;

    INSERT INTO diamonds_are_forever.transfer_to_lab(
        action_id, transfer_num, ship_date, lab_purpose)
    VALUES (v_action_id, p_transfer_num, p_ship_date, p_lab_purpose);

    INSERT INTO diamonds_are_forever.action_item(
        action_id, lot_id, price, currency_code)
    VALUES (v_action_id, p_lot_id, 0, 'USD');

    UPDATE diamonds_are_forever.item SET is_available = FALSE WHERE lot_id = p_lot_id;
END;
$$;
-- END PROCEDURE #4


-- BEGIN PROCEDURE #5
-- Description:
-- Transfer item to factory for processing
-- 1 Insert into action with category = 'transfer to factory'
-- 2 Insert into transfer_to_factory
-- 3 Insert into action_item
-- 4 Update item availability to FALSE
CREATE OR REPLACE PROCEDURE pcd_transfer_to_factory(
    p_office_id         INT,
    p_factory_id        INT,
    p_transfer_num      TEXT,
    p_ship_date         DATE,
    p_processing_type   diamonds_are_forever.processing_type,
    p_lot_id            INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action_id INT;
BEGIN
    INSERT INTO diamonds_are_forever.action(
        from_counterpart_id, to_counterpart_id, action_category, remarks)
    VALUES (p_office_id, p_factory_id, 'transfer to factory',
        'Item sent to factory for processing')
    RETURNING action_id INTO v_action_id;

    INSERT INTO diamonds_are_forever.transfer_to_factory(
        action_id, transfer_num, ship_date, processing_type)
    VALUES (v_action_id, p_transfer_num, p_ship_date, p_processing_type);

    INSERT INTO diamonds_are_forever.action_item(
        action_id, lot_id, price, currency_code)
    VALUES (v_action_id, p_lot_id, 0, 'USD');

    UPDATE diamonds_are_forever.item SET is_available = FALSE WHERE lot_id = p_lot_id;
END;
$$;
-- END PROCEDURE #5


-- BEGIN PROC #6
-- Description: register item's details, in this case it's white diamond
-- DROP FUNCTION IF EXISTS diamonds_are_forever.pcd_create_white_diamond_details;
CREATE OR REPLACE PROCEDURE pcd_create_white_diamond_details(
    it_lot_id      INT,
    ls_weight_ct   DECIMAL(5, 2),
    ls_shape       TEXT,
    ls_length      DECIMAL(4, 2),
    ls_width       DECIMAL(4, 2),
    ls_depth       DECIMAL(4, 2),
    wd_white_scale TEXT,
    wd_clarity     TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    ls_lot_id INT;
BEGIN
    INSERT INTO diamonds_are_forever.loose_stone (
        lot_id, weight_ct, shape, length, width, depth)
    VALUES (it_lot_id, ls_weight_ct,
        ls_shape::diamonds_are_forever.shape, ls_length, ls_width, ls_depth)
    RETURNING lot_id INTO ls_lot_id;

    INSERT INTO diamonds_are_forever.white_diamond (lot_id, white_scale, clarity)
    VALUES (ls_lot_id,
        wd_white_scale::diamonds_are_forever.white_scale,
        wd_clarity::diamonds_are_forever.clarity);

END;
$$;
-- END PROC #6

-- BEGIN PROC #7
-- Registering purchase of white diamond in one transaction
CREATE OR REPLACE PROCEDURE pcd_create_white_diamond(
    p_supplier_id           INT,
    p_office_id             INT,
    p_purchase_num          TEXT,
    p_stock_name            TEXT,
    p_origin                TEXT,
    p_item_type             TEXT,
    p_price                 NUMERIC,
    p_currency_code         TEXT,
    ls_weight_ct   DECIMAL(5, 2),
    ls_shape       TEXT,
    ls_length      DECIMAL(4, 2),
    ls_width       DECIMAL(4, 2),
    ls_depth       DECIMAL(4, 2),
    wd_white_scale TEXT,
    wd_clarity     TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    lot_id INT;
BEGIN
    CALL diamonds_are_forever.pcd_create_purchase(
        p_supplier_id,
        p_office_id,
        p_purchase_num,
        p_stock_name,
        p_origin,
        p_item_type::diamonds_are_forever.item_category,
        p_price,
        p_currency_code::diamonds_are_forever.code,
        lot_id
    );
    CALL diamonds_are_forever.pcd_create_white_diamond_details(
        lot_id,
        ls_weight_ct,
        ls_shape,
        ls_length,
        ls_width,
        ls_depth,
        wd_white_scale,
        wd_clarity
    );
END;
$$;
-- END PROC #7



-- ROLLBACK;
COMMIT;

