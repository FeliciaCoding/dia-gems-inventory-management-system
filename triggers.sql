SET search_path TO project;

-- BEGIN TRIGGER #2
-- Description:
-- Stone measurement update trigger (after factory processing)
-- When items return from factory with new measurements (after repolishing),
-- automatically update the loose_stone table with the new weight, dimensions,
-- and shape.

-- How to do it?
-- 1) back_from_factory is an action
-- actions are being connected with items by action_item
-- so the trigger needs to act on action_item
-- 2) it retrieves info from back_from_factory using action_item.action_id
-- 3) it sets this info into ... [problem]
-- [problem]:
-- if trigger acts on action_item table, it doesn't know
-- what is the underlying table (deep down in the inheritance hierarchy)
-- What to do then? Trigger could query
-- white_diamond, colored_diamond, colored_gem_stone and jewerly
-- one by one to check the "type" that belongs to action_item.log_id
-- Or we need to store underlying "type" in item table in the form of enum
-- but, it ruins generalization (inheritance)

CREATE OR REPLACE FUNCTION trig_a_i_back_from_fac()
    RETURNS TRIGGER AS
$$
BEGIN
    -- to be done
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_factory_processing_trigger
    AFTER INSERT
    ON action_item
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
        -- NOTE:
        -- That's strange
        -- Action is already created
        -- but only while creating Purchase we have a right
        -- to check this condition
        RAISE EXCEPTION 'action.from_counterpart_id does not equal supplier_id';
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
