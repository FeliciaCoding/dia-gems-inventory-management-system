SET search_path TO diamonds_are_forever;

-- BEGIN VIEW
-- Description:
-- Status for every jewelry registered in the system
CREATE VIEW complete_inventory_jewelry AS
SELECT i.lot_id,
       i.stock_name,
       i.origin,
       i.purchase_date,
       i.is_available,
       i.supplier_id,
       s.name     AS supplier_name,
       i.responsible_office_id,
       o.name     AS responsible_office,

       -- Where item actually is
       (SELECT c.name
          FROM action_item ai
               JOIN action a
               ON ai.action_id = a.action_id
               JOIN counterpart c
               ON a.to_counterpart_id = c.counterpart_id
         WHERE ai.lot_id = i.lot_id
         ORDER BY a.created_at DESC
         LIMIT 1) AS physical_location,

       CASE
          WHEN EXISTS (SELECT 1
                         FROM action_item ai
                              JOIN sale s
                              ON ai.action_id = s.action_id
                        WHERE ai.lot_id = i.lot_id) THEN 'Sold'
          WHEN EXISTS (SELECT 1
                         FROM action_item ai
                              JOIN memo_out mo
                              ON ai.action_id = mo.action_id
                        WHERE ai.lot_id = i.lot_id
                          AND NOT EXISTS (SELECT 1
                                            FROM return_memo_out rmo
                                           WHERE rmo.orig_memo_action_id = mo.action_id)) THEN 'On memo'
          WHEN EXISTS (SELECT 1
                         FROM action_item ai
                              JOIN transfer_to_factory ttf
                              ON ai.action_id = ttf.action_id
                        WHERE ai.lot_id = i.lot_id
                          AND NOT EXISTS (SELECT 1
                                            FROM back_from_factory bff
                                           WHERE bff.orig_transfer_id = ttf.action_id)) THEN 'In process'
          WHEN EXISTS (SELECT 1
                         FROM action_item ai
                              JOIN transfer_to_lab ttl
                              ON ai.action_id = ttl.action_id
                        WHERE ai.lot_id = i.lot_id
                          AND NOT EXISTS (SELECT 1
                                            FROM back_from_lab bfl
                                           WHERE bfl.orig_transfer_id = ttl.action_id)) THEN 'At lab'
          ELSE 'In stock'
          END     AS location_status,

       i.created_at,
       i.updated_at,
       c.certificate_num,
       lab.name AS certification_lab

  FROM item i
       LEFT JOIN counterpart s
       ON i.supplier_id = s.counterpart_id
       LEFT JOIN counterpart o
       ON i.responsible_office_id = o.counterpart_id
       LEFT JOIN jewelry j
       ON i.lot_id = j.lot_id
       LEFT JOIN certificate c
       ON i.lot_id = c.lot_id
       LEFT JOIN counterpart lab
       ON c.lab_id = lab.counterpart_id

 ORDER BY i.lot_id DESC;
-- END VIEW


-- BEGIN VIEW
-- Description:
-- Status on all colored gemstones
CREATE VIEW complete_inventory_colored_gem_stones AS
SELECT i.lot_id,
       i.stock_name,
       i.origin,
       i.purchase_date,
       i.is_available,
       i.supplier_id,
       s.name     AS supplier_name,
       i.responsible_office_id,
       o.name     AS responsible_office,

       -- Where item actually is
       (SELECT c.name
          FROM action_item ai
               JOIN action a
               ON ai.action_id = a.action_id
               JOIN counterpart c
               ON a.to_counterpart_id = c.counterpart_id
         WHERE ai.lot_id = i.lot_id
         ORDER BY a.created_at DESC
         LIMIT 1) AS physical_location,

       CASE
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN sale s
                               ON ai.action_id = s.action_id
                         WHERE ai.lot_id = i.lot_id) THEN 'Sold'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN memo_out mo
                               ON ai.action_id = mo.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM return_memo_out rmo
                                            WHERE rmo.orig_memo_action_id = mo.action_id)) THEN 'On memo'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN transfer_to_factory ttf
                               ON ai.action_id = ttf.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM back_from_factory bff
                                            WHERE bff.orig_transfer_id = ttf.action_id)) THEN 'In process'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN transfer_to_lab ttl
                               ON ai.action_id = ttl.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM back_from_lab bfl
                                            WHERE bfl.orig_transfer_id = ttl.action_id)) THEN 'At lab'
           ELSE 'In stock'
           END     AS location_status,

       ls.weight_ct,
       ls.shape,
       cgs.gem_color,
       cgs.treatment,
       i.created_at,
       i.updated_at,
       c.certificate_num,
       lab.name AS certification_lab

  FROM item i
       LEFT JOIN counterpart s
       ON i.supplier_id = s.counterpart_id
       LEFT JOIN counterpart o
       ON i.responsible_office_id = o.counterpart_id
       LEFT JOIN loose_stone ls
       ON i.lot_id = ls.lot_id
       LEFT JOIN colored_gem_stone cgs
       ON ls.lot_id = cgs.lot_id
       LEFT JOIN certificate c
       ON i.lot_id = c.lot_id
       LEFT JOIN counterpart lab
       ON c.lab_id = lab.counterpart_id

 ORDER BY i.lot_id DESC;
-- END VIEW


-- BEGIN VIEW
-- Description:
-- Status on all white diamonds
CREATE VIEW complete_inventory_white_diamonds AS
SELECT i.lot_id,
       i.stock_name,
       i.origin,
       i.purchase_date,
       i.is_available,
       i.supplier_id,
       s.name     AS supplier_name,
       i.responsible_office_id,
       o.name     AS responsible_office,

       -- Where item actually is
       (SELECT c.name
          FROM action_item ai
               JOIN action a
               ON ai.action_id = a.action_id
               JOIN counterpart c
               ON a.to_counterpart_id = c.counterpart_id
         WHERE ai.lot_id = i.lot_id
         ORDER BY a.created_at DESC
         LIMIT 1) AS physical_location,

       CASE
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN sale s
                               ON ai.action_id = s.action_id
                         WHERE ai.lot_id = i.lot_id) THEN 'Sold'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN memo_out mo
                               ON ai.action_id = mo.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM return_memo_out rmo
                                            WHERE rmo.orig_memo_action_id = mo.action_id)) THEN 'On memo'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN transfer_to_factory ttf
                               ON ai.action_id = ttf.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM back_from_factory bff
                                            WHERE bff.orig_transfer_id = ttf.action_id)) THEN 'In process'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN transfer_to_lab ttl
                               ON ai.action_id = ttl.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM back_from_lab bfl
                                            WHERE bfl.orig_transfer_id = ttl.action_id)) THEN 'At lab'
           ELSE 'In stock'
           END     AS location_status,

       ls.weight_ct,
       ls.shape,
       wd.white_scale,
       i.created_at,
       i.updated_at,
       c.certificate_num,
       lab.name AS certification_lab

  FROM item i
       LEFT JOIN counterpart s
       ON i.supplier_id = s.counterpart_id
       LEFT JOIN counterpart o
       ON i.responsible_office_id = o.counterpart_id
       LEFT JOIN loose_stone ls
       ON i.lot_id = ls.lot_id
       LEFT JOIN white_diamond wd
       ON ls.lot_id = wd.lot_id
       LEFT JOIN certificate c
       ON i.lot_id = c.lot_id
       LEFT JOIN counterpart lab
       ON c.lab_id = lab.counterpart_id

 ORDER BY i.lot_id DESC;
-- END VIEW


-- BEGIN VIEW
-- Description:
-- Status on all the colored diamonds
CREATE VIEW complete_inventory_colored_diamonds AS
SELECT i.lot_id,
       i.stock_name,
       i.origin,
       i.purchase_date,
       i.is_available,
       i.supplier_id,
       s.name     AS supplier_name,
       i.responsible_office_id,
       o.name     AS responsible_office,

       -- Where item actually is
       (SELECT c.name
          FROM action_item ai
               JOIN action a
               ON ai.action_id = a.action_id
               JOIN counterpart c
               ON a.to_counterpart_id = c.counterpart_id
         WHERE ai.lot_id = i.lot_id
         ORDER BY a.created_at DESC
         LIMIT 1) AS physical_location,

       CASE
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN sale s
                               ON ai.action_id = s.action_id
                         WHERE ai.lot_id = i.lot_id) THEN 'Sold'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN memo_out mo
                               ON ai.action_id = mo.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM return_memo_out rmo
                                            WHERE rmo.orig_memo_action_id = mo.action_id)) THEN 'On memo'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN transfer_to_factory ttf
                               ON ai.action_id = ttf.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM back_from_factory bff
                                            WHERE bff.orig_transfer_id = ttf.action_id)) THEN 'In process'
           WHEN EXISTS (SELECT 1
                          FROM action_item ai
                               JOIN transfer_to_lab ttl
                               ON ai.action_id = ttl.action_id
                         WHERE ai.lot_id = i.lot_id
                           AND NOT EXISTS (SELECT 1
                                             FROM back_from_lab bfl
                                            WHERE bfl.orig_transfer_id = ttl.action_id)) THEN 'At lab'
           ELSE 'In stock'
           END     AS location_status,

       ls.weight_ct,
       ls.shape,
       cd.fancy_intensity,
       cd.fancy_overtone,
       cd.fancy_color,
       cd.clarity,
       i.created_at,
       i.updated_at,
       c.certificate_num,
       lab.name AS certification_lab

  FROM item i
       LEFT JOIN counterpart s
       ON i.supplier_id = s.counterpart_id
       LEFT JOIN counterpart o
       ON i.responsible_office_id = o.counterpart_id
       LEFT JOIN loose_stone ls
       ON i.lot_id = ls.lot_id
       LEFT JOIN colored_diamond cd
       ON ls.lot_id = cd.lot_id
       LEFT JOIN certificate c
       ON i.lot_id = c.lot_id
       LEFT JOIN counterpart lab
       ON c.lab_id = lab.counterpart_id

 ORDER BY i.lot_id DESC;
-- END VIEW



CREATE VIEW available_inventory AS
SELECT i.lot_id,
       i.stock_name,
       i.origin,
       o.name     AS responsible_office,

       (SELECT c.name
          FROM action_item ai
               JOIN action a
               ON ai.action_id = a.action_id
               JOIN counterpart c
               ON a.to_counterpart_id = c.counterpart_id
         WHERE ai.lot_id = i.lot_id
         ORDER BY a.created_at DESC
         LIMIT 1) AS physical_location_name,

       CASE
          -- Check most recent transaction type
          WHEN EXISTS (SELECT 1
                         FROM action_item ai
                              JOIN sale s
                              ON ai.action_id = s.action_id
                        WHERE ai.lot_id = i.lot_id) THEN 'Sold'

          WHEN EXISTS (SELECT 1
                         FROM action_item ai
                              JOIN memo_out mo
                              ON ai.action_id = mo.action_id
                        WHERE ai.lot_id = i.lot_id
                          AND NOT EXISTS (SELECT 1
                                            FROM return_memo_out rmo
                                           WHERE rmo.orig_memo_action_id = mo.action_id)) THEN 'On memo'

          WHEN EXISTS (SELECT 1
                         FROM action_item ai
                              JOIN transfer_to_factory ttf
                              ON ai.action_id = ttf.action_id
                        WHERE ai.lot_id = i.lot_id
                          AND NOT EXISTS (SELECT 1
                                            FROM back_from_factory bff
                                           WHERE bff.orig_transfer_id = ttf.action_id)) THEN 'In process'

          WHEN EXISTS (SELECT 1
                         FROM action_item ai
                              JOIN transfer_to_lab ttl
                              ON ai.action_id = ttl.action_id
                        WHERE ai.lot_id = i.lot_id
                          AND NOT EXISTS (SELECT 1
                                            FROM back_from_lab bfl
                                           WHERE bfl.orig_transfer_id = ttl.action_id)) THEN 'At lab'

          ELSE 'In stock'
          END     AS location_status,

       CASE
          WHEN wd.lot_id IS NOT NULL THEN 'White Diamond'
          WHEN cd.lot_id IS NOT NULL THEN 'Colored Diamond'
          WHEN cgs.lot_id IS NOT NULL THEN 'Colored Gemstone'
          WHEN j.lot_id IS NOT NULL THEN 'Jewelry'
          ELSE 'Unknown'
          END     AS item_type,

       ls.weight_ct,
       ls.shape,
       wd.white_scale,
       cd.fancy_intensity,
       cd.fancy_overtone,
       cd.fancy_color,
       cgs.gem_color,
       cd.clarity,
       cgs.treatment,
       i.created_at,
       i.updated_at,
       lab.name   AS lab_name,
       c.certificate_num

  FROM item i
       LEFT JOIN counterpart o
       ON i.responsible_office_id = o.counterpart_id
       LEFT JOIN loose_stone ls
       ON i.lot_id = ls.lot_id
       LEFT JOIN white_diamond wd
       ON ls.lot_id = wd.lot_id
       LEFT JOIN colored_diamond cd
       ON ls.lot_id = cd.lot_id
       LEFT JOIN colored_gem_stone cgs
       ON ls.lot_id = cgs.lot_id
       LEFT JOIN jewelry j
       ON i.lot_id = j.lot_id
       LEFT JOIN certificate c
       ON i.lot_id = c.lot_id
       LEFT JOIN counterpart lab
       ON c.lab_id = lab.counterpart_id

 WHERE i.is_available = TRUE

 ORDER BY item_type, ls.weight_ct DESC;


--  Inventory by Type
--  -> Count how many white diamonds, colored diamonds, gemstones, and jewelry pieces we have
CREATE VIEW inventory_by_type AS
SELECT

    CASE
        WHEN wd.lot_id IS NOT NULL THEN 'White Diamond'
        WHEN cd.lot_id IS NOT NULL THEN 'Colored Diamond'
        WHEN cgs.lot_id IS NOT NULL THEN 'Colored Gemstone'
        WHEN j.lot_id IS NOT NULL THEN 'Jewelry'
        ELSE 'Unknown'
    END AS item_type,


    COUNT(*) AS total_count,
    SUM(CASE WHEN i.is_available = TRUE THEN 1 ELSE 0 END) AS available_count,
    SUM(CASE WHEN i.is_available = FALSE THEN 1 ELSE 0 END) AS unavailable_count,

    -- for loose stones only
    ROUND(SUM(COALESCE(ls.weight_ct, 0))::NUMERIC, 2) AS total_weight_ct,
    ROUND(AVG(COALESCE(ls.weight_ct, 0))::NUMERIC, 2) AS avg_weight_ct

FROM item i
LEFT JOIN loose_stone ls ON i.lot_id = ls.lot_id
LEFT JOIN white_diamond wd ON ls.lot_id = wd.lot_id
LEFT JOIN colored_diamond cd ON ls.lot_id = cd.lot_id
LEFT JOIN colored_gem_stone cgs ON ls.lot_id = cgs.lot_id
LEFT JOIN jewelry j ON i.lot_id = j.lot_id

GROUP BY item_type
ORDER BY total_count DESC;

--test
SELECT * FROM complete_inventory_jewelry;
SELECT * FROM complete_inventory_colored_gem_stones;
SELECT * FROM complete_inventory_white_diamonds;
SELECT * FROM complete_inventory_colored_diamonds;
SELECT * FROM available_inventory;
SELECT * FROM inventory_by_type;