
-- testing :
BEGIN;

--Set disponsibility = false && responsible office = 1
INSERT INTO item (stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available) VALUES
('testing', '2025-12-10 10:00:00+00', 5, 'South Africa', 1, FALSE);

SELECT * FROM item where stock_name = 'testing';

-- Testing responsible office : responsible office should set to 2 as to_counterpart_id = 2
INSERT INTO action (from_counterpart_id, to_counterpart_id, terms, remarks) VALUES
(5, 2, 'Payment: Upon delivery', 'testing purchase');

SELECT * FROM action where remarks = 'testing purchase';


INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code) VALUES
(21, 73, 1, 18500.00, 'USD');
SELECT * FROM action_item where action_id = 21;


-- Testing : Availability should be Ture
INSERT INTO purchase (action_id, purchase_num, purchase_date) VALUES
(21, 'PO-testing_id20', '2025-01-15');
SELECT * FROM purchase where action_id = 21;

SELECT * FROM item where stock_name = 'testng';
SELECT lot_id, responsible_office_id, is_available FROM item where stock_name = 'testing';

ROLLBACK ;



