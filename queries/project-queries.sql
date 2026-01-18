SET search_path TO diamonds_are_forever;


-- Query #1
-- Show all available white diamonds for preparing a proposition to client
SELECT lot_id,
       stock_name,
       weight_ct,
       shape,
       white_scale,
       certification_lab,
       certificate_num,
       physical_location
  FROM complete_inventory_white_diamonds
 WHERE location_status = 'In stock'
   AND is_available = TRUE
 ORDER BY weight_ct DESC;


-- Query #2
-- Show all items currently on memo out
SELECT lot_id, stock_name, physical_location, supplier_name, weight_ct, 'Colored Diamond' AS item_type
  FROM complete_inventory_colored_diamonds
 WHERE location_status = 'On memo'

 UNION ALL

SELECT lot_id, stock_name, physical_location, supplier_name, weight_ct, 'White Diamond'
  FROM complete_inventory_white_diamonds
 WHERE location_status = 'On memo'

 UNION ALL

SELECT lot_id, stock_name, physical_location, supplier_name, weight_ct, 'Colored Gemstone'
  FROM complete_inventory_colored_gem_stones
 WHERE location_status = 'On memo'

 UNION ALL

SELECT lot_id, stock_name, physical_location, supplier_name, NULL AS weight_ct, 'Jewelry'
  FROM complete_inventory_jewelry
 WHERE location_status = 'On memo';


-- Query # 3
-- Identify items which need to be follow up for updating data
SELECT 'Colored Diamond' as item_type, lot_id, stock_name,
       physical_location, location_status
FROM complete_inventory_colored_diamonds
WHERE location_status IN ('At lab', 'In process')

UNION ALL

SELECT 'White Diamond', lot_id, stock_name,
       physical_location, location_status
FROM complete_inventory_white_diamonds
WHERE location_status IN ('At lab', 'In process')

UNION ALL

SELECT 'Colored Gemstone', lot_id, stock_name,
       physical_location, location_status
FROM complete_inventory_colored_gem_stones
WHERE location_status IN ('At lab', 'In process');


-- Query # 4
-- Quick summery if the inventory, category by location_status
SELECT location_status, COUNT(*) as count
FROM (
    SELECT location_status FROM complete_inventory_colored_diamonds
    UNION ALL
    SELECT location_status FROM complete_inventory_white_diamonds
    UNION ALL
    SELECT location_status FROM complete_inventory_colored_gem_stones
    UNION ALL
    SELECT location_status FROM complete_inventory_jewelry
) all_items
GROUP BY location_status;

-- Query # 5
-- Make a purchase (without certificate)
CALL diamonds_are_forever.pcd_create_white_diamond(
    5,
    1,
    'PO-TEST-0002',
    'TEST-WD-0002',
    'South Africa',
    'white diamond',
    18000.00,
    'USD',
    3.12,
    'Emerald Cut',
    4.12,
    4.51,
    3.12,
    'S',
    'VS'
);

-- Query #6
-- Make a new sale
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


-- Query #7
-- Make a new memo-out (sale without payment)
CALL pcd_create_memo_out(
    1,
    13,
    'MO-TEST-0002',
    CURRENT_DATE,
    (CURRENT_DATE + 14)::DATE,
    42,
    35000.00,
    'USD'::code
);


