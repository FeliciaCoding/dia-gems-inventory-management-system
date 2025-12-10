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

