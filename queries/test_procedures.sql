SET search_path TO diamonds_are_forever;
BEGIN ;

-- BEGIN TEST CASE PROCEDURE #1
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

-- END TEST CASE PROCEDURE #1


-- BEGIN TEST CASE PROCEDURE #2
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
--END TEST CASE PROCEDURE #2


-- BEGIN TEST CASE PROCEDURE #3
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
-- END TEST CASE PROCEDURE #3