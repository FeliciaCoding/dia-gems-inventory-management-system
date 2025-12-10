
BEGIN ;

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
          is_available = TRUE
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

--ROLLBACK ;
--COMMIT;