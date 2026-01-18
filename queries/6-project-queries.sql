SET search_path TO diamonds_are_forever;
BEGIN;
--ROLLBACK;


-- BEGIN QUERY #1
-- SHOW ALL AVAILABLE WHITE DIAMONDS FOR PREPARING AN PROPOSITION TO CLIENT

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
-- END QUERY #1


-- BEGIN QUERY #2
-- SHOW ALL ITEMS CURRENTLY ON MEMO OUT
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

-- END QUERY #2

-- BEGIN QUERY # 3
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
-- Quick summery if the inventory, catagory by location_status
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

