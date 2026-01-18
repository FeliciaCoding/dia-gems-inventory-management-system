

some ideas for interesting view/procedure/query/trigger


# Interesting views / triggers / query / procedure 


1. View: Comput "location status" as 'Sold', 'On memo', 'In process', 'At lab' and 'In stock'. 

```sql
CREATE OR REPLACE VIEW complete_inventory_colored_gem_stones AS
SELECT DISTINCT ON (i.lot_id)
       i.lot_id,
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
                                            WHERE rmo.orig_transfer_id = mo.action_id)) THEN 'On memo'
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
           END    AS location_status,

       ls.weight_ct,
       ls.shape,
       cgs.gem_color,
       cgs.treatment,
       i.created_at,
       i.updated_at,
       c.certificate_num,
       c.is_valid AS is_cert_valid,
       lab.name   AS certification_lab

  FROM item i
       INNER JOIN loose_stone ls
       ON i.lot_id = ls.lot_id

       INNER JOIN colored_gem_stone cgs
       ON ls.lot_id = cgs.lot_id

       INNER JOIN counterpart s
       ON i.supplier_id = s.counterpart_id

       INNER JOIN counterpart o
       ON i.responsible_office_id = o.counterpart_id

       LEFT JOIN certificate c
       ON i.lot_id = c.lot_id

       LEFT JOIN counterpart lab
       ON c.lab_id = lab.counterpart_id

 ORDER BY i.lot_id, c.created_at DESC;
-- END VIEW
```

2. Queries : Extract a list of goods which are currently on memo out
    Purpose :  Before the important, the company can recall back all the goods which is currently on memo out.
``` sql

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
```

3. Query : Identify items which need to be follow up for updating data
    purpose : To follow up the items which may have impact on market value and will need to update the database. 

```sql
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

```

4.Trigger : automatically update stone's dimension after returning back from the factory 
purpose : automatically update dimensions after recut.
```sql
-- BEGIN TRIGGER #2
CREATE OR REPLACE FUNCTION trig_a_i_back_from_fac()
    RETURNS TRIGGER AS
$$
DECLARE
    item_id INTEGER;
    ls_item diamonds_are_forever.loose_stone%ROWTYPE;
BEGIN
    item_id := (
        SELECT lot_id
        FROM diamonds_are_forever.action_item
        WHERE new.action_id = action_item.action_id
        LIMIT 1
    );

    -- save the previous measurements
    SELECT * INTO ls_item
    FROM diamonds_are_forever.loose_stone
    WHERE lot_id = item_id;

    new.before_weight_ct = ls_item.weight_ct;
    new.before_shape = ls_item.shape;
    new.before_length = ls_item.length;
    new.before_width = ls_item.width;
    new.before_depth = ls_item.depth;

    new.weight_loss_ct = new.before_weight_ct - new.after_weight_ct;

    UPDATE diamonds_are_forever.loose_stone
    SET weight_ct = COALESCE(new.after_weight_ct, new.before_weight_ct),
        shape = COALESCE(new.after_shape, new.before_shape),
        length = COALESCE(new.after_length, new.before_length),
        width = COALESCE(new.after_width, new.before_width),
        depth = COALESCE(new.after_depth, new.before_depth)
    WHERE lot_id = item_id;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_factory_processing_trigger
    BEFORE INSERT
    ON back_from_factory
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_back_from_fac();
```

5. trigger : when crearting **"Retrun"**, the system need to verify if the goods are initially from the corresponding **Actions**
    purpose : Avoiding returning false / irrelevant items

```sql
CREATE OR REPLACE FUNCTION trig_b_i_return_items_check()
    RETURNS TRIGGER AS
$$
DECLARE
    mistaken_item_id   INTEGER;
    original_action_id INTEGER;
BEGIN

    FOR mistaken_item_id IN
        WITH orig_action_items_ids AS (
            SELECT lot_id
            FROM diamonds_are_forever.action_item ai
            WHERE ai.action_id = new.orig_transfer_id
        ),
        returned_items_ids AS (
            SELECT lot_id
            FROM diamonds_are_forever.action_item ai
            WHERE ai.action_id = new.action_id
        )
        SELECT lot_id
        FROM returned_items_ids
        EXCEPT
        SELECT lot_id
        FROM orig_action_items_ids
    LOOP
        RAISE EXCEPTION 'Some of returned items were not listed in the original action (%) : %',
            original_action_id, mistaken_item_id;
    END LOOP;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_returning_items_memo_in_trigger
    BEFORE INSERT
    ON return_memo_in
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_return_items_check();

CREATE TRIGGER check_returning_items_memo_out_trigger
    BEFORE INSERT
    ON return_memo_out
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_return_items_check();

CREATE TRIGGER check_returning_items_back_from_lab_trigger
    BEFORE INSERT
    ON back_from_lab
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_return_items_check();

CREATE TRIGGER check_returning_items_back_from_factory_trigger
    BEFORE INSERT
    ON back_from_factory
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_return_items_check();

```

6. Procedure : When creating new sale, update automatically `action_category = 'sale'` and link the price to the final sale price.

```
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
```