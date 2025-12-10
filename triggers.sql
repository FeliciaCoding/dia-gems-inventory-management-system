SET search_path TO project;

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

-- What is the order of row insertion when new item is bought?
-- let's say it is a white_diamond
-- 1) insert a row into item
-- 2) insert a row into white_diamond
-- 3) insert a row into action
-- ??? then it's either
-- 4) insert a row into action_item
-- 5) insert a row into purchase
-- ?? or
-- 4) insert a row into purchase
-- 5) insert a row into action_item
-- Which way to go?
-- Supposing it's 1st approach

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
-- I think we should have several triggers one per each:
-- 1) Memo In - Return Memo IN
-- 2) Memo Out - Return Memo Out
-- 3) Transfer To Lab - Back From Lab
-- 4) and for the factory we already have the trigger #2

CREATE OR REPLACE FUNCTION trig_b_i_memo_in_items_check()
    RETURNS TRIGGER AS
$$
BEGIN
    -- extract ids of all memo in items
    SELECT lot_id
    FROM action_item ai
    WHERE ai.action_id = new.orig_memo_action_id;

    -- NOTE:
    -- I think we've got another problem here
    -- to find out ids of returned items
    -- we need to use action_item table
    -- so rows should have been inserted there already
    -- but, it has been done already
    -- what is the point of checking them here?

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_log_seq_num_trigger
    BEFORE INSERT
    ON return_memo_in
    FOR EACH ROW
EXECUTE FUNCTION trig_b_i_memo_in_items_check();

-- END TRIGGER #7



