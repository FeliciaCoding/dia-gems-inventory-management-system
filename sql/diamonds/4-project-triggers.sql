SET search_path TO diamonds_are_forever;

-- BEGIN TRIGGER #1
-- Description: responsible_office_id should be updated everytime
-- item has been 'moved' as well as its availability

CREATE OR REPLACE FUNCTION trig_a_i_keep_track_responsible_office()
    RETURNS TRIGGER AS
$$
DECLARE
    counterpart_col_name text;
    item_availability bool;
    dynamic_sql text;
BEGIN
    IF TG_TABLE_NAME IN ('return_memo_out', 'back_from_factory', 'back_from_lab') THEN
        counterpart_col_name := 'to_counterpart_id';
        item_availability := TRUE;
    ELSIF TG_TABLE_NAME IN ('return_memo_in', 'memo_out', 'transfer_to_factory', 'transfer_to_lab', 'sale') THEN
        counterpart_col_name := 'from_counterpart_id';
        item_availability := FALSE;
    ELSE -- transfer_to_office
        counterpart_col_name := 'from_counterpart_id';
        item_availability := TRUE;
    END IF;

    dynamic_sql := FORMAT(
        $sql$
        UPDATE diamonds_are_forever.item
            SET responsible_office_id = (
                SELECT %I
                FROM diamonds_are_forever.action
                WHERE action_id = $1
            ),
            updated_at   = NOW(),
            is_available = $2
        WHERE lot_id IN (
            SELECT lot_id
            FROM diamonds_are_forever.action_item
            WHERE action_id = $1
        )
        $sql$,
        counterpart_col_name
    );

    EXECUTE dynamic_sql
        USING NEW.action_id, item_availability;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER responsible_office_after_purchase_trigger
    AFTER INSERT
    ON purchase
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_memo_in_trigger
    AFTER INSERT
    ON memo_in
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_return_memo_in_trigger
    AFTER INSERT
    ON return_memo_in
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_memo_out_trigger
    AFTER INSERT
    ON memo_out
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_return_memo_out_trigger
    AFTER INSERT
    ON return_memo_out
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_transfer_to_factory_trigger
    AFTER INSERT
    ON transfer_to_factory
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_back_from_factory_trigger
    AFTER INSERT
    ON back_from_factory
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_transfer_to_lab_trigger
    AFTER INSERT
    ON transfer_to_lab
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_back_from_lab_trigger
    AFTER INSERT
    ON back_from_lab
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_transfer_to_office_trigger
    AFTER INSERT
    ON transfer_to_office
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();

CREATE TRIGGER responsible_office_after_sale_trigger
    AFTER INSERT
    ON sale
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_keep_track_responsible_office();
-- END TRIGGER #1

-- BEGIN TRIGGER #2
-- Description:
-- Stone measurement update trigger (after factory processing)
-- When items return from factory with new measurements (after repolishing),
-- automatically update the loose_stone table with the new weight, dimensions,
-- and shape.

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
    FROM loose_stone
    WHERE lot_id = item_id;

    new.before_weight_ct = ls_item.weight_ct;
    new.before_shape = ls_item.shape;
    new.before_length = ls_item.length;
    new.before_widht = ls_item.width;
    new.before_depth = ls_item.depth;

    UPDATE diamonds_are_forever.loose_stone
    SET weight_ct = new.after_weight_ct,
        shape = new.after_shape,
        length = new.after_length,
        width = new.after_width,
        depth = new.after_depth
    WHERE lot_id = item_id;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_factory_processing_trigger
    AFTER INSERT
    ON back_from_factory
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_back_from_fac();

-- END TRIGGER #2

-- BEGIN TRIGGER #6

-- DROP TRIGGER IF EXISTS verify_supplier_on_purchase_trigger ON purchase;
-- DROP FUNCTION IF EXISTS trig_b_i_purchase;

-- Purchase:
-- When inserting into Purchase table supplier_id of all concerned items
-- should equal to from_counterpart_id of Purchase.Action
-- (connected via Action Item relationship)
-- If it is not - update and raise a warning

CREATE OR REPLACE FUNCTION trig_b_i_purchase()
    RETURNS TRIGGER AS
$$
DECLARE
    counterpart_id INTEGER;
    supplier_id INTEGER;
    item_id INTEGER;
BEGIN
    -- action.from_counterpart_id == item.supplier_id
    counterpart_id := (
        SELECT from_counterpart_id
        FROM diamonds_are_forever.action a
        WHERE a.action_id = new.action_id
        LIMIT 1
    );

    -- since one purchase (from one counterpart) can
    -- include several items we need to look at every of them
    FOR supplier_id, item_id IN
        SELECT it.supplier_id, it.lot_id
        FROM diamonds_are_forever.action_item ai
            INNER JOIN diamonds_are_forever.item it
            ON it.lot_id = ai.lot_id
        WHERE ai.action_id = new.action_id
    LOOP

        IF counterpart_id <> supplier_id THEN
            UPDATE diamonds_are_forever.item
            SET supplier_id = supplier_id
            WHERE item.lot_id = item_id;
            RAISE WARNING 'item(%).supplier(%) does not equal to purchase.action(%).from_counterpart_id(%). Updating item.supplier_id ...',
                item_id, supplier_id, new.action_id, counterpart_id;
        END IF;
    END LOOP;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verify_supplier_on_purchase_trigger
    BEFORE INSERT
    ON purchase
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_purchase();


-- END TRIGGER #6

-- BEGIN TRIGGER #7
-- Description based on an example:
-- 4 items were put in Memo Out and send somewhere
-- 2 items came back
-- we want to register those 2 in Return Memo Out
-- trigger should automatically verify that those 2 items were indeed put in memo out
-- and nobody tries to trick the system by returning the wrong items

CREATE OR REPLACE FUNCTION trig_b_i_return_items_check()
    RETURNS TRIGGER AS
$$
DECLARE
    mistaken_item_id   INTEGER;
    original_action_id INTEGER;
BEGIN
    -- NOTE:
    -- Since `return_memo_in` inherits attributes from `action`
    -- it has FK to its parent entity
    -- In this trigger we suppose that corresponding row has been already inserted into `action`
    -- and corresponding links to the items that are being returned have been created in `action_item` as well
    -- So, here we will simply verify that these links (rows in `action_item`) point correctly
    -- to the items that were indeed memo-in once
    -- If there is an item that violates this check exception will be raised
    -- and hopefully transaction fails
    -- (we suppose that all necessary inserts to action-memoin-action_item happen in one transaction)

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

-- END TRIGGER #7

-- BEGIN TRIGGER #8
-- Description:
-- On every purchase check if purchase-action is indeed
-- involving a supplier counterpart
CREATE OR REPLACE FUNCTION trig_b_i_true_supplier_check()
    RETURNS TRIGGER AS
$$
DECLARE
    supplier_id INTEGER;
BEGIN
    -- NOTE:
    -- We suppose that purchase is the last row that is being inserted during
    -- action-action_item-purchase suite

    FOR supplier_id IN
        SELECT from_counterpart_id
        FROM diamonds_are_forever.action
        WHERE action_id = new.action_id
        ORDER BY created_at DESC
    LOOP
        IF NOT EXISTS(
            SELECT *
            FROM diamonds_are_forever.counterpart_account_type cat
                INNER JOIN diamonds_are_forever.account_type at
                ON cat.type_name = at.type_name
            WHERE cat.counterpart_id = supplier_id AND
                at.category = 'Supplier'
        ) THEN
            RAISE EXCEPTION 'Trying to register purchase from the counterpart (%) that is not a supplier', supplier_id;
        END IF;
    END LOOP;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_if_true_supplier_purchase_trigger
    BEFORE INSERT
    ON purchase
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_true_supplier_check();

-- END TRIGGER #8


-- BEGIN TRIGGER #9
-- Description:
-- Check that client-counterpart is involved in sale
CREATE OR REPLACE FUNCTION trig_b_i_client_sale_check()
    RETURNS TRIGGER AS
$$
DECLARE
    client_id INTEGER;
BEGIN
    FOR client_id IN
        SELECT to_counterpart_id
        FROM diamonds_are_forever.action
        WHERE action_id = new.action_id
        ORDER BY created_at DESC
    LOOP
        IF NOT EXISTS(
            SELECT *
            FROM diamonds_are_forever.counterpart_account_type cat
                INNER JOIN diamonds_are_forever.account_type at
                ON cat.type_name = at.type_name
            WHERE cat.counterpart_id = client_id AND
                  at.category = 'Client'
        ) THEN
            RAISE EXCEPTION 'Trying to register sale for the counterpart (%) that is not a client', client_id;
        END IF;
    END LOOP;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_if_true_client_sale_trigger
    BEFORE INSERT
    ON sale
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_client_sale_check();

-- END TRIGGER #9

-- BEGIN TRIGGER #10
-- Description: verify that item has not been already sold
-- before registering a sale-action
CREATE OR REPLACE FUNCTION trig_b_i_not_sold_twice()
    RETURNS TRIGGER AS
$$
DECLARE
    item_id INTEGER;
    prev_sale_id INTEGER;
BEGIN
    FOR item_id IN
        SELECT ai.lot_id
        FROM diamonds_are_forever.action_item ai
        WHERE ai.action_id = new.action_id
    LOOP
         prev_sale_id := (
             SELECT s.action_id
             FROM diamonds_are_forever.sale s
                 INNER JOIN diamonds_are_forever.action a
                 ON s.action_id = a.action_id
                 INNER JOIN diamonds_are_forever.action_item ai
                 ON s.action_id = ai.action_id
             WHERE ai.lot_id = item_id
         );

        IF item_id IS NOT NULL AND prev_sale_id IS NOT NULL THEN
            RAISE EXCEPTION 'Item (%) has been already sold in action (%)',
                item_id, prev_sale_id;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_sold_twice_trigger
    BEFORE INSERT
    ON sale
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_not_sold_twice();
-- END TRIGGER #10


-- BEGIN TRIGGER #10
-- Description:
-- update updated_at timestamp whenever records in action, item, certificate,
-- counterpart, or employee tables are modified
CREATE OR REPLACE FUNCTION trig_a_u_keep_updated_at_fresh()
    RETURNS TRIGGER AS
$$
BEGIN
    new.updated_at = NOW();
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER counterpart_updated_at_trigger
    AFTER UPDATE
    ON counterpart
    FOR EACH ROW
EXECUTE FUNCTION trig_a_u_keep_updated_at_fresh();

CREATE TRIGGER employee_updated_at_trigger
    AFTER UPDATE
    ON employee
    FOR EACH ROW
EXECUTE FUNCTION trig_a_u_keep_updated_at_fresh();

CREATE TRIGGER action_updated_at_trigger
    AFTER UPDATE
    ON action
    FOR EACH ROW
EXECUTE FUNCTION trig_a_u_keep_updated_at_fresh();

CREATE TRIGGER item_updated_at_trigger
    AFTER UPDATE
    ON item
    FOR EACH ROW
EXECUTE FUNCTION trig_a_u_keep_updated_at_fresh();

CREATE TRIGGER certificate_updated_at_trigger
    AFTER UPDATE
    ON certificate
    FOR EACH ROW
EXECUTE FUNCTION trig_a_u_keep_updated_at_fresh();

-- END TRIGGER #10


-- BEGIN TRIGGER #11
-- Description:
-- After stone has been returned from factory
-- all its certificates should be no longer valid
CREATE OR REPLACE FUNCTION trig_a_i_invalidate_certificates()
    RETURNS TRIGGER AS
$$
DECLARE
    item_id INTEGER;
    cert diamonds_are_forever.certificate%ROWTYPE;
BEGIN
    -- for all returned back from factory items
    FOR item_id IN
        SELECT ai.lot_id
        FROM diamonds_are_forever.back_from_factory bff
            INNER JOIN diamonds_are_forever.action_item ai
            ON bff.action_id = ai.action_id
        WHERE bff.action_id = new.action_id
    LOOP
        -- for every certificate of every item
        FOR cert IN
            SELECT *
            FROM diamonds_are_forever.certificate
            WHERE lot_id = item_id
        LOOP
            -- make certificate invalid
            IF cert.is_valid THEN
                UPDATE diamonds_are_forever.certificate c
                SET is_valid = FALSE
                WHERE c.certificate_id = cert.certificate_id;
            END IF;
        END LOOP;
    END LOOP;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER invalidate_certificates_after_factory_trigger
    AFTER INSERT
    ON back_from_factory
    FOR EACH ROW
EXECUTE FUNCTION trig_a_i_invalidate_certificates();
-- END TRIGGER #11


-- BEGIN TRIGGER #11
-- Description:
-- Since we would like to reflect:
-- - new certificates after re-certification
-- - new measurements after re-cutting/polishing
-- We would like to reduce relationship between Action and Item
-- from many-to-many to many-to-one for certain cases: Back from lab, Back from Factory
-- (if we've received 10 items back from factory we must insert
--  10 rows in back from factory while specifying the same back_from_fac_num
--  and orig_transfer_id everywhere)
CREATE OR REPLACE FUNCTION trig_b_i_one_item_per_back_from_lab_factory()
    RETURNS TRIGGER AS
$$
DECLARE
    n_items INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO n_items
    FROM  diamonds_are_forever.action_item ai
    WHERE ai.action_id = new.action_id;

    IF n_items > 1 THEN
        RAISE EXCEPTION 'Expected to have only one item per one back_from_lab/back_from_factory. But % have been assigned for %',
            n_items, new.action_id;
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_one_item_per_one_back_from_lab_trigger
    BEFORE INSERT
    ON back_from_lab
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_one_item_per_back_from_lab_factory();

CREATE TRIGGER ensure_one_item_per_one_back_from_factory_trigger
    BEFORE INSERT
    ON back_from_factory
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_one_item_per_back_from_lab_factory();
-- END TRIGGER #11


-- BEGIN TRIGGER #12
-- Description:
-- Disallow selling stones (white diamonds/colored diamonds/colore gemstones)
-- without valid certificate
CREATE OR REPLACE FUNCTION trig_b_i_sale_without_valid_certificate()
    RETURNS TRIGGER AS
$$
DECLARE
    item_id INTEGER;
    cert_id INTEGER;
BEGIN
    FOR item_id, cert_id IN
        SELECT ai.lot_id
        FROM diamonds_are_forever.sale s
            INNER JOIN diamonds_are_forever.action_item ai
            ON s.action_id = ai.action_id
            -- join on certificate will automatically
            -- remove the tuples with jewelry
            -- since they do not have the certificates at all
            INNER JOIN diamonds_are_forever.certificate c
            ON ai.lot_id = c.lot_id
        WHERE c.is_valid = FALSE
    LOOP
        RAISE EXCEPTION 'Selling stones (white diamonds/colored diamonds/colore gemstones) without valid certificate is disallowed. But in sale (%) stone (%) has invalid certificate (%)',
            new.action_id, item_id, cert_id;
    END LOOP;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER disallow_sell_stones_without_valid_cert_trigger
    BEFORE INSERT
    ON sale
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_sale_without_valid_certificate();
-- END TRIGGER #12
