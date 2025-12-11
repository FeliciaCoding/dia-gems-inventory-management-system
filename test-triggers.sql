SET search_path TO project;


-- BEGIN TEST CASE TRIGGER #2
-- Description:
-- after registering return from factory
-- loose_stone should be updated

BEGIN;

-- 1. Create colored diamond
INSERT INTO item (lot_id, stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available)
VALUES (61, 'CD-2024-011', '2024-06-22 10:04:00+00', 7, 'Australia', 3, TRUE);
INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth)
VALUES (61, 1.14, 'Brilliant Cut', 5.92, 3.89, 4.28);
INSERT INTO colored_diamond (lot_id, gem_type, fancy_intensity, fancy_overtone, fancy_color, clarity)
VALUES (61, 'Diamond', 'Fancy', 'None', 'Yellow', 'VS1');

-- 2. Register a purchase
INSERT INTO action (action_id, from_counterpart_id, to_counterpart_id, terms, remarks, created_at, updated_at)
VALUES (11, 7, 3, 'Payment: Upon delivery', 'Kashmir sapphires, rare collection', '2024-03-15 14:00:00+00', '2024-03-15 14:00:00+00');
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code)
VALUES (11, 61, 1, 15300.00, 'USD');
INSERT INTO purchase (action_id, purchase_num, purchase_date)
VALUES (11, 'PO-2024-0006', '2024-03-15');

-- 3. Checkout info of the colored diamond
SELECT lot_id, weight_ct, shape, length, width, depth
FROM loose_stone
WHERE lot_id = 61;

-- 4. Transfer to a factory
INSERT INTO action (action_id, from_counterpart_id, to_counterpart_id, terms, remarks, created_at, updated_at)
VALUES (12, 3, 22, 'Payment: 30 days net', 'Kashmir sapphires, rare collection', '2024-03-15 14:00:00+00', '2024-03-15 14:00:00+00');
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code)
VALUES (12, 61, 1, 15300.00, 'USD');
INSERT INTO transfer_to_factory (action_id, transfer_num, ship_date, processing_type)
VALUES (12, 'FA-2024-0001', '2024-06-01', 'Recut');

-- 5. Register arrival from factory
INSERT INTO action (action_id, from_counterpart_id, to_counterpart_id, terms, remarks, created_at, updated_at)
VALUES (13, 22, 3, 'Payment: 30 days net', 'Kashmir sapphires, rare collection', '2024-03-15 14:00:00+00', '2024-03-15 14:00:00+00');
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code)
VALUES (13, 61, 1, 15300.00, 'USD');
INSERT INTO back_from_factory (action_id, orig_transfer_id, back_from_fac_num, back_date, after_weight_ct, after_shape, after_length, after_width, after_depth, weight_loss_ct)
VALUES (13, 12, 'BF-2024-0001', '2024-07-11', 1.10, 'Heart Shape', 5.51, 3.25, 3.22, 0.04);

-- 6. Checkout info of the colored diamond again
SELECT lot_id, weight_ct, shape, length, width, depth
FROM loose_stone
WHERE lot_id = 61;

ROLLBACK;

-- END TEST CASE TRIGGER #2


-- BEGIN TEST CASE TRIGGER #6
-- Description:
-- while registering the purchase
-- make sure that from_counterpart_id from action matches supplier_id in item
-- raise a warning and update from_counterpart_id if it does not

BEGIN;

-- 1. Create colored diamond (or any other item)
INSERT INTO item (lot_id, stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available)
VALUES (62, 'CD-2024-012', '2024-06-24 10:04:00+00', 7, 'Australia', 3, TRUE);
INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth)
VALUES (62, 2.04, 'Brilliant Cut', 7.92, 5.11, 5.18);
INSERT INTO colored_diamond (lot_id, gem_type, fancy_intensity, fancy_overtone, fancy_color, clarity)
VALUES (62, 'Diamond', 'Fancy', 'None', 'Yellow', 'VS1');

-- 2. Register a purchase (1)
INSERT INTO action (action_id, from_counterpart_id, to_counterpart_id, terms, remarks, created_at, updated_at)
VALUES (12, 5, 3, 'Payment: Upon delivery', 'Kashmir sapphires, rare collection', '2024-06-24 14:00:00+00', '2024-06-24 14:00:00+00');
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code)
VALUES (12, 62, 1, 25300.00, 'USD');

-- 3. Checkout the wrong value
SELECT a.action_id,
       from_counterpart_id,
       c1.name AS supplier,
       to_counterpart_id,
       c2.name AS office
FROM action a
    INNER JOIN counterpart c1
    ON c1.counterpart_id = a.from_counterpart_id

    INNER JOIN counterpart c2
    ON c2.counterpart_id = a.to_counterpart_id
WHERE action_id = 12;

-- 4. Register a purchase (continue)
INSERT INTO purchase (action_id, purchase_num, purchase_date)
VALUES (12, 'PO-2024-0007', '2024-06-24');

-- 5. Checkout that supplier (from_counterpart_id) in action
-- has been adjusted according to info from item
SELECT action_id,
       from_counterpart_id,
       c1.name AS supplier,
       to_counterpart_id,
       c2.name AS office
  FROM action
       INNER JOIN counterpart c1
       ON c1.counterpart_id = from_counterpart_id

       INNER JOIN counterpart c2
       ON c2.counterpart_id = to_counterpart_id
 WHERE action_id = 12;

ROLLBACK;

-- END TEST CASE TRIGGER #6

