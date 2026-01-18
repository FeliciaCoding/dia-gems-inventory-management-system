SET search_path TO diamonds_are_forever;
BEGIN;
--ROLLBACK;


-- BEGIN QUERY #1
-- SHOW ALL AVAILABLE WHITE DIAMONDS

SELECT lot_id, stock_name, weight_ct, shape, white_scale,
       certification_lab, certificate_num, physical_location
FROM complete_inventory_white_diamonds
WHERE location_status = 'In stock'
  AND is_available = TRUE
ORDER BY weight_ct DESC;
-- END QUERY #1



