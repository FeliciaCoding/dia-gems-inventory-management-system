SET search_path TO project;

-- BEGIN TRIGGER #1
-- purchase, memo in , returns , back form
CREATE OR REPLACE FUNCTION update_responsible_office_after_inbound()
    RETURNS TRIGGER AS
$$
BEGIN
    UPDATE item
       SET responsible_office_id = (SELECT to_counterpart_id
                                      FROM action
                                     WHERE action_id = new.action_id),
           updated_at            = NOW(),
           is_available          = TRUE
     WHERE lot_id IN (SELECT lot_id
                        FROM action_item
                       WHERE action_id = new.action_id);

    RETURN new;
END;
$$ LANGUAGE plpgsql;

-- sold, memo out, transfer to lab/factory
CREATE OR REPLACE FUNCTION update_responsible_office_after_outbound()
    RETURNS TRIGGER AS
$$
BEGIN
    UPDATE item
       SET responsible_office_id = (SELECT from_counterpart_id
                                      FROM action
                                     WHERE action_id = new.action_id),
           updated_at            = NOW(),
           is_available = FALSE
     WHERE lot_id IN (SELECT lot_id
                        FROM action_item
                       WHERE action_id = new.action_id);

    RETURN new;
END;
$$ LANGUAGE plpgsql;

-- between offices - is_available is always true
CREATE OR REPLACE FUNCTION update_responsible_office_after_transfer_office()
    RETURNS TRIGGER AS
$$
BEGIN
    UPDATE item
       SET responsible_office_id = (SELECT from_counterpart_id
                                      FROM action
                                     WHERE action_id = new.action_id),
           updated_at            = NOW(),
           is_available = TRUE
     WHERE lot_id IN (SELECT lot_id
                        FROM action_item
                       WHERE action_id = new.action_id);

    RETURN new;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER trigger_responsible_office_after_purchase
    AFTER INSERT
    ON purchase
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_inbound();

CREATE TRIGGER trigger_responsible_office_after_memo_in
    AFTER INSERT
    ON memo_in
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_inbound();

CREATE TRIGGER trigger_responsible_office_after_return_memo_in
    AFTER INSERT
    ON return_memo_in
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_outbound();


CREATE TRIGGER trigger_responsible_office_after_memo_out
    AFTER INSERT
    ON memo_out
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_outbound();

CREATE TRIGGER trigger_responsible_office_after_return_memo_out
    AFTER INSERT
    ON return_memo_out
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_inbound();

CREATE TRIGGER trigger_responsible_office_after_transfer_to_factory
    AFTER INSERT
    ON transfer_to_factory
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_outbound();

CREATE TRIGGER trigger_responsible_office_after_back_from_factory
    AFTER INSERT
    ON back_from_factory
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_inbound();


CREATE TRIGGER trigger_responsible_office_after_transfer_to_lab
    AFTER INSERT
    ON transfer_to_lab
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_outbound();


CREATE TRIGGER trigger_responsible_office_after_back_from_lab
    AFTER INSERT
    ON back_from_lab
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_inbound();


CREATE TRIGGER trigger_responsible_office_after_transfer_to_office
    AFTER INSERT
    ON transfer_to_office
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_transfer_office();

CREATE TRIGGER trigger_responsible_office_after_sale
    AFTER INSERT
    ON sale
    FOR EACH ROW
EXECUTE FUNCTION update_responsible_office_after_outbound();
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
BEGIN
    item_id := (
        SELECT lot_id
        FROM action_item
        WHERE new.action_id = action_item.action_id
        LIMIT 1
    );

    UPDATE loose_stone
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


-- BEGIN TRIGGER #4

-- Audit Log Sequence Generator:
-- Automatically generate sequential log numbers (1, 2, 3...)
-- for each action would make t easy to see the order of changes.

CREATE OR REPLACE FUNCTION trig_b_i_update_log()
    RETURNS TRIGGER AS
$$
BEGIN
    SELECT log_sequence + 1
    INTO new.log_sequence
    FROM action_update_log
    WHERE action_id = new.action_id
    ORDER BY log_sequence DESC
    LIMIT 1;
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_log_seq_num_trigger
    BEFORE INSERT
    ON action_update_log
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_update_log();

-- END TRIGGER #4

-- BEGIN TRIGGER #6

-- Purchase:
-- When inserting into Purchase table from_counterpart_id should be equal
-- to the supplier_id in corresponding Item (connected via Action Item relationship)
-- If it is not - update and raise a warning

CREATE OR REPLACE FUNCTION trig_b_i_purchase()
    RETURNS TRIGGER AS
$$
DECLARE
    counterpart_id INTEGER;
    supplier_id INTEGER;
BEGIN
    -- action.from_counterpart_id == item.supplier_id
    counterpart_id := (
        SELECT from_counterpart_id
        FROM action a
        WHERE a.action_id = new.action_id
        LIMIT 1
    );

    supplier_id := (
        SELECT supplier_id
        FROM action_item ai
            INNER JOIN item it
            ON it.lot_id = ai.lot_id
        WHERE ai.action_id = new.action_id
        LIMIT 1
    );

    IF counterpart_id <> supplier_id THEN
        UPDATE action
        SET from_counterpart_id = supplier_id
        WHERE action.action_id = new.action_id;
        RAISE WARNING 'action.from_counterpart_id does not equal supplier_id. Updating action.from_counterpart_id from supplier_id';
    END IF;

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
-- and nobody tries to trick the system by putting the wrong items there

-- NOTE:
-- We should have several triggers one per each:
-- 1) Memo In - Return Memo IN
-- 2) Memo Out - Return Memo Out
-- 3) Transfer To Lab - Back From Lab
-- 4) and for the factory we already have the trigger #2

CREATE OR REPLACE FUNCTION trig_b_i_memo_in_items_check()
    RETURNS TRIGGER AS
$$
DECLARE
    mistaken_item_id INTEGER;
BEGIN
    -- NOTE:
    -- Since `return_memo_in` inherits attributes from `action`
    -- it has FK to its parent entity
    -- In this trigger we suppose that corresponding row has been already inserted into `action`
    -- and corresponding links to the items that are being returned have been created as well in `action_item`
    -- Here we will simply verify that these links (rows from `action_item`) correctly point
    -- to the items that were indeed memo in once

    FOR mistaken_item_id IN
        WITH orig_memo_in_items_ids AS (
            SELECT lot_id
              FROM action_item ai
             WHERE ai.action_id = new.orig_memo_action_id
        ), returned_items_ids AS (
            SELECT lot_id
            FROM action_item ai
            WHERE ai.action_id = new.action_id
        )
        SELECT lot_id
        FROM returned_items_ids
        EXCEPT
        SELECT lot_id
        FROM orig_memo_in_items_ids
    LOOP
        RAISE WARNING 'Some of returned items were issued in original memo in (%) : %',
            new.orig_memo_action_id, mistaken_item_id;
    END LOOP;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_log_seq_num_trigger
    BEFORE INSERT
    ON return_memo_in
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_memo_in_items_check();

-- END TRIGGER #7



