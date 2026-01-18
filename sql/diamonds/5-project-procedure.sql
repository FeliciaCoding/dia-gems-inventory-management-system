SET search_path TO diamonds_are_forever;
BEGIN;
ROLLBACK;

--Begin procedure # 1
-- Description:
-- Create a new purchase :
-- 1. Creates a new item (lot_id auto-generated)
-- 2. creates a purchase action,
-- 3. links the new lot to the purchase with price/currency.
CREATE OR REPLACE PROCEDURE pcd_create_purchase(
    p_supplier_id           INT,
    p_office_id             INT,
    p_purchase_num          TEXT,
    p_stock_name            TEXT,
    p_origin                TEXT,
    p_item_type             item_category,
    p_price                 NUMERIC,
    p_currency_code         code
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_lot_id    INT;
    v_action_id INT;
BEGIN
    -- Create the item (lot_id generated automatically)
    INSERT INTO item(stock_name, supplier_id, origin, responsible_office_id, item_type)
    VALUES (p_stock_name, p_supplier_id, p_origin, p_office_id, p_item_type)
    RETURNING lot_id INTO v_lot_id;

    -- Create action header for purchase (supplier -> office)
    INSERT INTO action(from_counterpart_id, to_counterpart_id, action_category, remarks)
    VALUES (p_supplier_id, p_office_id, 'purchase', 'Purchase created via procedure')
    RETURNING action_id INTO v_action_id;

    -- specify the purchase
    INSERT INTO purchase(action_id, purchase_num)
    VALUES (v_action_id, p_purchase_num);

    -- Link item to action with price/currency
    INSERT INTO action_item(action_id, lot_id, price, currency_code)
    VALUES (v_action_id, v_lot_id, p_price, p_currency_code);
END;
$$;
-- END PROCEDURE #1

CALL pcd_create_purchase(
    5,
    1,
    'PO-TEST-0001',
    'TEST-WD-0001',
    'South Africa',
    'white diamond'::item_category,
    18000.00,
    'USD'::code
);

SELECT *
FROM purchase p
JOIN action a USING (action_id)
JOIN action_item ai USING (action_id)
ORDER BY p.action_id DESC
LIMIT 1;


-- BEGIN PROCEDURE #2
-- Description:
-- Create new MEMO OUT:
-- 1 Insert into action with category = 'memo out', to_counterpart_id = client/partner receiving goods
-- 2 Insert into memo_out
-- 3 Insert into action_item with price + currency
CREATE OR REPLACE PROCEDURE pcd_create_memo_out(
    office_id           INT,
    client_id           INT,
    in_memo_out_num        TEXT,
    in_ship_date           DATE,
    in_expected_return     DATE,
    in_lot_id              INT,
    memo_price               NUMERIC,
    in_currency_code       code
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action_id INT;
BEGIN
    INSERT INTO action(from_counterpart_id, to_counterpart_id, action_category, remarks)
    VALUES (office_id, client_id, 'memo out', 'Memo out created via procedure')
    RETURNING action_id INTO v_action_id;

    INSERT INTO memo_out(action_id, memo_out_num, ship_date, expected_return_date)
    VALUES (v_action_id, in_memo_out_num, in_ship_date, in_expected_return);

    INSERT INTO action_item(action_id, lot_id, price, currency_code)
    VALUES (v_action_id, in_lot_id, memo_price, in_currency_code);
END;
$$;
-- END PROCEDURE #2

CALL pcd_create_memo_out(
    1,
    13,
    'MO-TEST-0001',
    CURRENT_DATE,
    (CURRENT_DATE + 14)::DATE,
    42,
    35000.00,
    'USD'::code
);


SELECT *
FROM memo_out m
JOIN action a USING (action_id)
JOIN action_item ai USING (action_id)
ORDER BY m.action_id DESC
LIMIT 1;

-- BEGIN PROCEDURE #3
-- Create new sale :
-- 1 Creates a new action with action_category = 'sale' and links the sender office to the buyer
-- 2 Creates the sale document record in the sale table
-- 3 Links the sold lot to the sale action in action_item with its price and currency.
--
CREATE OR REPLACE PROCEDURE pcd_create_sale(
    office_id        INT,
    client_id        INT,
    in_sale_num         TEXT,
    in_payment_method   TEXT,
    in_payment_status   payment_status,
    in_lot_id           INT,
    final_sale_price            NUMERIC,
    in_currency_code    code
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action_id INT;
BEGIN
    INSERT INTO action(from_counterpart_id, to_counterpart_id, action_category, remarks)
    VALUES (office_id, client_id, 'sale', 'Sale created via procedure')
    RETURNING action_id INTO v_action_id;

    INSERT INTO sale(action_id, sale_num, payment_method, payment_status)
    VALUES (v_action_id, in_sale_num, in_payment_method, in_payment_status);

    INSERT INTO action_item(action_id, lot_id, price, currency_code)
    VALUES (v_action_id, in_lot_id, final_sale_price, in_currency_code);
END;
$$;
-- END PROCEDURE #3

CALL pcd_create_sale(
    2,
    15,
    'SO-TEST-001',
    'Wire Transfer',
    'Unpaid'::payment_status,
    34,
    52000.00,
    'USD'::code
);


SELECT *
FROM diamonds_are_forever.sale s
JOIN diamonds_are_forever.action a USING (action_id)
JOIN diamonds_are_forever.action_item ai USING (action_id)
ORDER BY s.action_id DESC
LIMIT 1;