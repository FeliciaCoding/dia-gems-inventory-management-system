-- Dummy data was generated with a help of ChatGPT

SET search_path TO diamonds_are_forever;

BEGIN;


INSERT INTO currency (code, name) VALUES
('USD', 'United States Dollar'),
('HKD', 'Hong Kong Dollar'),
('CHF', 'Swiss Franc'),
('EUR', 'Euro'),
('NTD', 'New Taiwan Dollar');


INSERT INTO account_type (type_name, category, is_internal) VALUES
('Diamond Supplier', 'Supplier', FALSE),
('Jewelry Supplier', 'Supplier', FALSE),
('Colored Gem Supplier', 'Supplier', FALSE),
('Retail Client', 'Client', FALSE),
('Diamond Wholesaler', 'Client', FALSE),
('Jewelry Wholesaler', 'Client', FALSE),
('Certification Lab', 'Lab', FALSE),
('Processing Manufacturer', 'Manufacturer', FALSE),
('NY Office', 'Office', TRUE),
('HK Office', 'Office', TRUE),
('Geneva Office', 'Office', TRUE),
('Tokyo Office', 'Office', TRUE);


-- Offices (Internal)
INSERT INTO counterpart (counterpart_id, name, phone_number, address_short, city, postal_code, country, email, is_active) VALUES
(1, 'New York Office', '+1-212-555-0101', '580 5th Ave', 'New York', '10036', 'USA', 'ny@gemcompany.com', TRUE),
(2, 'Hong Kong Office', '+852-2345-6789', '88 Queensway', 'Hong Kong', '999077', 'Hong Kong', 'hk@gemcompany.com', TRUE),
(3, 'Geneva Office', '+41-44-555-0102', 'Bahnhofstrasse 45', 'Geneva', '1201', 'Switzerland', 'geneva@gemcompany.com', TRUE),
(4, 'Tokyo Office', '+81-3-5555-1234', '1-2-3 Ginza', 'Tokyo', '104-0061', 'Japan', 'tokyo@gemcompany.com', TRUE);

-- Diamond Suppliers
INSERT INTO counterpart (counterpart_id, name, phone_number, address_short, city, postal_code, country, email, is_active) VALUES
(5, 'Antwerp Diamond Exchange', '+32-3-234-5678', 'Pelikaanstraat 62', 'Antwerp', '2018', 'Belgium', 'info@antwerpdiamonds.be', TRUE),
(6, 'Mumbai Diamond House', '+91-22-2345-6789', 'Opera House', 'Mumbai', '400004', 'India', 'sales@mumbaidia.in', TRUE),
(7, 'Tel Aviv Gem Co', '+972-3-517-8888', 'Ramat Gan', 'Tel Aviv', '5252100', 'Israel', 'contact@telavivgems.il', TRUE),
(8, 'Botswana Diamond Corp', '+267-318-0000', 'Plot 64518', 'Gaborone', '00000', 'Botswana', 'export@bwdiamonds.bw', TRUE);

-- Colored Gem Suppliers
INSERT INTO counterpart (counterpart_id, name, phone_number, address_short, city, postal_code, country, email, is_active) VALUES
(9, 'Bangkok Ruby Traders', '+66-2-234-5678', '919 Silom Road', 'Bangkok', '10500', 'Thailand', 'sales@bangkokruby.th', TRUE),
(10, 'Colombian Emerald Source', '+57-1-234-5678', 'Carrera 7', 'Bogota', '110111', 'Colombia', 'info@colombiaemeralds.co', TRUE),
(11, 'Kashmir Sapphire Ltd', '+91-194-245-6789', 'Residency Road', 'Srinagar', '190001', 'India', 'contact@kashmirsapphire.in', TRUE),
(12, 'Myanmar Ruby Export', '+95-1-234-567', 'Merchant Street', 'Yangon', '11182', 'Myanmar', 'export@myanmarruby.mm', TRUE);

-- Retail Clients
INSERT INTO counterpart (counterpart_id, name, phone_number, address_short, city, postal_code, country, email, is_active) VALUES
(13, 'Tiffany & Partners', '+1-212-755-8000', '727 5th Avenue', 'New York', '10022', 'USA', 'wholesale@tiffanypartners.com', TRUE),
(14, 'Cartier Geneva SA', '+41-22-818-1010', 'Rue du Rhone 35', 'Geneva', '1204', 'Switzerland', 'orders@cartiergeneva.ch', TRUE),
(15, 'Van Cleef Tokyo', '+81-3-5561-8888', '2-10-1 Ginza', 'Tokyo', '104-0061', 'Japan', 'purchasing@vancleeftokyo.jp', TRUE),
(16, 'Bulgari Hong Kong', '+852-2524-6888', 'Canton Road 3', 'Hong Kong', '999077', 'Hong Kong', 'sales@bulgarihk.com', TRUE);

-- Certification Labs
INSERT INTO counterpart (counterpart_id, name, phone_number, address_short, city, postal_code, country, email, is_active) VALUES
(17, 'GIA Laboratory', '+1-760-603-4500', '5345 Armada Drive', 'Carlsbad', '92008', 'USA', 'lab@gia.edu', TRUE),
(18, 'IGI International', '+32-3-201-0581', 'Schupstraat 1', 'Antwerp', '2018', 'Belgium', 'info@igi.org', TRUE),
(19, 'HRD Antwerp', '+32-3-222-0511', 'Hoveniersstraat 22', 'Antwerp', '2018', 'Belgium', 'info@hrdantwerp.com', TRUE),
(20, 'AGS Laboratories', '+1-702-255-6757', '3309 Juanita Street', 'Las Vegas', '89102', 'USA', 'lab@ags.org', TRUE);

-- Processing Manufacturers
INSERT INTO counterpart (counterpart_id, name, phone_number, address_short, city, postal_code, country, email, is_active) VALUES
(21, 'Surat Diamond Cutting', '+91-261-234-5678', 'Mini Bazaar', 'Surat', '395002', 'India', 'factory@suratcutting.in', TRUE),
(22, 'Antwerp Precision Cut', '+32-3-232-8899', 'Lange Herentalsestraat', 'Antwerp', '2018', 'Belgium', 'production@antwerpcut.be', TRUE),
(23, 'Bangkok Gem Processing', '+66-2-234-9999', 'Jewelry Trade Center', 'Bangkok', '10500', 'Thailand', 'service@bangkokprocess.th', TRUE);

-- Jewelry Wholesalers
INSERT INTO counterpart (counterpart_id, name, phone_number, address_short, city, postal_code, country, email, is_active) VALUES
(24, 'Global Jewelry Distributors', '+1-213-622-1000', '650 S Hill Street', 'Los Angeles', '90014', 'USA', 'orders@globaljewelry.com', TRUE),
(25, 'European Luxury Imports', '+49-89-2345-6789', 'Maximilianstrasse 12', 'Munich', '80539', 'Germany', 'sales@euluxury.de', TRUE),
(26, 'Asian Fine Jewelry Co', '+852-2815-5555', 'Nathan Road 378', 'Hong Kong', '999077', 'Hong Kong', 'wholesale@asianfinejewelry.com', TRUE);


INSERT INTO counterpart_account_type (counterpart_id, type_name) VALUES
-- Offices
(1, 'NY Office'), (2, 'HK Office'), (3, 'Geneva Office'), (4, 'Tokyo Office'),
-- Diamond Suppliers
(5, 'Diamond Supplier'), (6, 'Diamond Supplier'), (7, 'Diamond Supplier'), (8, 'Diamond Supplier'),
-- Colored Gem Suppliers
(9, 'Colored Gem Supplier'), (10, 'Colored Gem Supplier'), (11, 'Colored Gem Supplier'), (12, 'Colored Gem Supplier'),
-- Retail Clients
(13, 'Retail Client'), (14, 'Retail Client'), (15, 'Retail Client'), (16, 'Retail Client'),
-- Labs
(17, 'Certification Lab'), (18, 'Certification Lab'), (19, 'Certification Lab'), (20, 'Certification Lab'),
-- Manufacturers
(21, 'Processing Manufacturer'), (22, 'Processing Manufacturer'), (23, 'Processing Manufacturer'),
-- Wholesalers
(24, 'Diamond Wholesaler'), (25, 'Jewelry Wholesaler'), (26, 'Jewelry Wholesaler');


INSERT INTO employee (employee_id, counterpart_id, first_name, last_name, email, role, is_active) VALUES
-- NY Office Staff
(1, 1, 'John', 'Smith', 'john.smith@example.com', 'Chief', TRUE),
(2, 1, 'Sarah', 'Johnson', 'sarah.johnson@example.com', 'Admin', TRUE),
(3, 1, 'Michael', 'Williams', 'michael.williams@example.com', 'Sales', TRUE),
(4, 1, 'Emily', 'Brown', 'emily.brown@example.com', 'Accountant', TRUE),
-- HK Office Staff
(5, 2, 'David', 'Chen', 'david.chen@example.com', 'Chief', TRUE),
(6, 2, 'Lisa', 'Wong', 'lisa.wong@example.com', 'Admin', TRUE),
(7, 2, 'Kevin', 'Lee', 'kevin.lee@example.com', 'Sales', TRUE),
-- Geneva Office Staff
(8, 3, 'Hans', 'Mueller', 'hans.mueller@example.com', 'Chief', TRUE),
(9, 3, 'Anna', 'Schmidt', 'anna.schmidt@example.com', 'Sales', TRUE),
(10, 3, 'Thomas', 'Weber', 'thomas.weber@example.comm', 'Accountant', TRUE),
-- Tokyo Office Staff
(11, 4, 'Yuki', 'Tanaka', 'yuki.tanaka@example.com', 'Chief', TRUE),
(12, 4, 'Sakura', 'Yamamoto', 'sakura.yamamoto@example.com', 'Sales', TRUE);



-- White Diamonds (15 items)
INSERT INTO item (lot_id, stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available) VALUES
(1, 'WD-2024-001', '2024-01-15 10:00:00+00', 5, 'South Africa', 1, TRUE),
(2, 'WD-2024-002', '2024-01-20 14:30:00+00', 5, 'Botswana', 1, TRUE),
(3, 'WD-2024-003', '2024-02-05 09:15:00+00', 6, 'India', 2, TRUE),
(4, 'WD-2024-004', '2024-02-10 11:45:00+00', 7, 'Russia', 3, TRUE),
(5, 'WD-2024-005', '2024-02-15 13:20:00+00', 8, 'Botswana', 1, TRUE),
(6, 'WD-2024-006', '2024-03-01 10:30:00+00', 5, 'South Africa', 1, TRUE),
(7, 'WD-2024-007', '2024-03-10 15:00:00+00', 6, 'Australia', 2, TRUE),
(8, 'WD-2024-008', '2024-03-15 09:45:00+00', 7, 'Canada', 3, TRUE),
(9, 'WD-2024-009', '2024-04-01 14:15:00+00', 5, 'South Africa', 1, TRUE),
(10, 'WD-2024-010', '2024-04-10 11:30:00+00', 8, 'Botswana', 1, TRUE),
(11, 'WD-2024-011', '2024-04-20 10:00:00+00', 6, 'India', 2, TRUE),
(12, 'WD-2024-012', '2024-05-05 13:45:00+00', 7, 'Russia', 3, TRUE),
(13, 'WD-2024-013', '2024-05-15 09:30:00+00', 5, 'South Africa', 1, TRUE),
(14, 'WD-2024-014', '2024-05-25 14:20:00+00', 8, 'Botswana', 1, TRUE),
(15, 'WD-2024-015', '2024-06-01 10:15:00+00', 6, 'Australia', 2, TRUE);

-- Colored Diamonds (10 items)
INSERT INTO item (lot_id, stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available) VALUES
(16, 'CD-2024-001', '2024-01-25 11:00:00+00', 5, 'South Africa', 1, TRUE),
(17, 'CD-2024-002', '2024-02-12 15:30:00+00', 7, 'Australia', 3, TRUE),
(18, 'CD-2024-003', '2024-03-08 10:45:00+00', 6, 'India', 2, TRUE),
(19, 'CD-2024-004', '2024-03-22 14:00:00+00', 5, 'South Africa', 1, TRUE),
(20, 'CD-2024-005', '2024-04-15 09:20:00+00', 8, 'Botswana', 1, TRUE),
(21, 'CD-2024-006', '2024-04-28 13:50:00+00', 7, 'Russia', 3, TRUE),
(22, 'CD-2024-007', '2024-05-10 11:15:00+00', 6, 'Australia', 2, TRUE),
(23, 'CD-2024-008', '2024-05-20 15:40:00+00', 5, 'South Africa', 1, TRUE),
(24, 'CD-2024-009', '2024-06-05 10:30:00+00', 8, 'Botswana', 1, TRUE),
(25, 'CD-2024-010', '2024-06-15 14:10:00+00', 7, 'Canada', 3, TRUE);

-- Rubies (8 items)
INSERT INTO item (lot_id, stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available) VALUES
(26, 'RB-2024-001', '2024-01-18 09:30:00+00', 9, 'Thailand', 2, TRUE),
(27, 'RB-2024-002', '2024-02-08 14:45:00+00', 12, 'Myanmar', 2, TRUE),
(28, 'RB-2024-003', '2024-03-12 10:20:00+00', 9, 'Thailand', 2, TRUE),
(29, 'RB-2024-004', '2024-04-05 15:15:00+00', 12, 'Myanmar', 2, TRUE),
(30, 'RB-2024-005', '2024-04-25 11:40:00+00', 9, 'Madagascar', 2, TRUE),
(31, 'RB-2024-006', '2024-05-12 13:25:00+00', 12, 'Myanmar', 2, TRUE),
(32, 'RB-2024-007', '2024-05-28 09:50:00+00', 9, 'Thailand', 2, TRUE),
(33, 'RB-2024-008', '2024-06-10 14:35:00+00', 12, 'Myanmar', 2, TRUE);

-- Sapphires (8 items)
INSERT INTO item (lot_id, stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available) VALUES
(34, 'SP-2024-001', '2024-01-22 10:15:00+00', 11, 'Kashmir', 2, TRUE),
(35, 'SP-2024-002', '2024-02-14 15:30:00+00', 9, 'Sri Lanka', 2, TRUE),
(36, 'SP-2024-003', '2024-03-05 09:45:00+00', 11, 'Kashmir', 2, TRUE),
(37, 'SP-2024-004', '2024-03-28 14:20:00+00', 9, 'Madagascar', 2, TRUE),
(38, 'SP-2024-005', '2024-04-18 11:10:00+00', 11, 'Kashmir', 2, TRUE),
(39, 'SP-2024-006', '2024-05-08 13:55:00+00', 9, 'Sri Lanka', 2, TRUE),
(40, 'SP-2024-007', '2024-05-22 10:40:00+00', 11, 'Kashmir', 2, TRUE),
(41, 'SP-2024-008', '2024-06-12 15:25:00+00', 9, 'Australia', 2, TRUE);

-- Emeralds (6 items)
INSERT INTO item (lot_id, stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available) VALUES
(42, 'EM-2024-001', '2024-02-01 11:20:00+00', 10, 'Colombia', 1, TRUE),
(43, 'EM-2024-002', '2024-03-15 14:40:00+00', 10, 'Colombia', 1, TRUE),
(44, 'EM-2024-003', '2024-04-08 09:55:00+00', 10, 'Zambia', 1, TRUE),
(45, 'EM-2024-004', '2024-04-30 13:15:00+00', 10, 'Colombia', 1, TRUE),
(46, 'EM-2024-005', '2024-05-18 10:45:00+00', 10, 'Brazil', 1, TRUE),
(47, 'EM-2024-006', '2024-06-08 15:10:00+00', 10, 'Colombia', 1, TRUE);

-- Jewelry Items (13 items)
INSERT INTO item (lot_id, stock_name, purchase_date, supplier_id, origin, responsible_office_id, is_available) VALUES
(48, 'JW-2024-001', '2024-01-10 09:00:00+00', 13, 'USA', 1, TRUE),
(49, 'JW-2024-002', '2024-01-28 14:30:00+00', 14, 'Switzerland', 3, TRUE),
(50, 'JW-2024-003', '2024-02-18 11:15:00+00', 15, 'Japan', 4, TRUE),
(51, 'JW-2024-004', '2024-03-02 15:45:00+00', 16, 'Italy', 3, TRUE),
(52, 'JW-2024-005', '2024-03-20 10:20:00+00', 13, 'USA', 1, TRUE),
(53, 'JW-2024-006', '2024-04-12 13:40:00+00', 14, 'Switzerland', 3, TRUE),
(54, 'JW-2024-007', '2024-04-22 09:25:00+00', 15, 'Japan', 4, TRUE),
(55, 'JW-2024-008', '2024-05-03 14:50:00+00', 16, 'France', 3, TRUE),
(56, 'JW-2024-009', '2024-05-16 11:35:00+00', 13, 'USA', 1, TRUE),
(57, 'JW-2024-010', '2024-05-30 15:05:00+00', 14, 'Switzerland', 3, TRUE),
(58, 'JW-2024-011', '2024-06-06 10:50:00+00', 15, 'Japan', 4, TRUE),
(59, 'JW-2024-012', '2024-06-14 13:20:00+00', 16, 'Italy', 3, TRUE),
(60, 'JW-2024-013', '2024-06-20 09:40:00+00', 13, 'USA', 1, TRUE);


-- White Diamonds (15 loose stones)
INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth) VALUES
(1, 1.52, 'Brilliant Cut', 7.45, 7.42, 4.58),
(2, 2.03, 'Brilliant Cut', 8.15, 8.12, 5.02),
(3, 0.75, 'Princess', 5.32, 5.29, 3.88),
(4, 3.21, 'Emerald Cut', 10.12, 8.05, 5.67),
(5, 1.08, 'Brilliant Cut', 6.58, 6.55, 4.05),
(6, 2.54, 'Oval', 9.85, 7.32, 4.95),
(7, 0.92, 'Pear Shape', 7.12, 5.48, 3.45),
(8, 1.75, 'Brilliant Cut', 7.85, 7.82, 4.82),
(9, 4.15, 'Brilliant Cut', 10.58, 10.55, 6.52),
(10, 1.32, 'Princess', 6.25, 6.22, 4.32),
(11, 0.58, 'Brilliant Cut', 5.28, 5.25, 3.25),
(12, 2.88, 'Radiant Cut', 8.95, 8.12, 5.35),
(13, 1.95, 'Brilliant Cut', 8.05, 8.02, 4.95),
(14, 3.42, 'Oval', 11.25, 8.45, 5.78),
(15, 1.18, 'Heart Shape', 7.05, 6.98, 4.15);

-- Colored Diamonds (10 loose stones)
INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth) VALUES
(16, 1.85, 'Brilliant Cut', 7.92, 7.89, 4.88),
(17, 2.34, 'Radiant Cut', 8.45, 7.58, 4.92),
(18, 0.88, 'Princess', 5.68, 5.65, 3.95),
(19, 1.52, 'Oval', 8.15, 6.32, 4.25),
(20, 3.15, 'Brilliant Cut', 9.85, 9.82, 6.08),
(21, 1.05, 'Pear Shape', 7.45, 5.82, 3.68),
(22, 2.08, 'Brilliant Cut', 8.25, 8.22, 5.08),
(23, 1.42, 'Radiant Cut', 7.35, 6.82, 4.45),
(24, 2.75, 'Oval', 9.45, 7.25, 4.88),
(25, 1.68, 'Brilliant Cut', 7.75, 7.72, 4.78);

-- Rubies (8 loose stones)
INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth) VALUES
(26, 2.45, 'Oval', 8.85, 6.75, 4.52),
(27, 3.82, 'Oval', 10.25, 8.15, 5.35),
(28, 1.68, 'Oval', 7.95, 6.05, 4.08),
(29, 5.12, 'Oval', 11.85, 9.25, 6.15),
(30, 2.95, 'Oval', 9.35, 7.45, 4.88),
(31, 4.25, 'Oval', 10.95, 8.85, 5.75),
(32, 1.92, 'Oval', 8.15, 6.35, 4.25),
(33, 3.45, 'Oval', 10.05, 7.95, 5.25);

-- Sapphires (8 loose stones)
INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth) VALUES
(34, 3.15, 'Oval', 9.75, 7.85, 5.12),
(35, 2.28, 'Oval', 8.65, 6.95, 4.55),
(36, 4.52, 'Oval', 11.15, 9.05, 5.98),
(37, 1.85, 'Oval', 8.05, 6.45, 4.22),
(38, 5.35, 'Oval', 12.25, 9.85, 6.48),
(39, 2.75, 'Oval', 9.15, 7.35, 4.82),
(40, 3.88, 'Oval', 10.45, 8.45, 5.58),
(41, 2.05, 'Oval', 8.35, 6.65, 4.38);

-- Emeralds (6 loose stones)
INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth) VALUES
(42, 2.85, 'Emerald Cut', 9.25, 7.15, 5.05),
(43, 3.95, 'Emerald Cut', 10.65, 8.25, 5.85),
(44, 1.75, 'Emerald Cut', 7.85, 6.05, 4.35),
(45, 4.58, 'Emerald Cut', 11.45, 8.95, 6.28),
(46, 2.35, 'Emerald Cut', 8.75, 6.75, 4.75),
(47, 3.28, 'Emerald Cut', 9.95, 7.75, 5.48);


INSERT INTO white_diamond (lot_id, white_scale, clarity) VALUES
(1, 'F', 'VS1'),
(2, 'D', 'VVS2'),
(3, 'G', 'VS2'),
(4, 'E', 'VVS1'),
(5, 'H', 'VS1'),
(6, 'D', 'IF'),
(7, 'G', 'VS2'),
(8, 'F', 'VVS2'),
(9, 'D', 'FL'),
(10, 'G', 'VS1'),
(11, 'H', 'VS2'),
(12, 'E', 'VVS1'),
(13, 'F', 'VS1'),
(14, 'D', 'VVS2'),
(15, 'G', 'VS2');


INSERT INTO colored_diamond (lot_id, gem_type, fancy_intensity, fancy_overtone, fancy_color, clarity) VALUES
(16, 'Diamond', 'Fancy', 'None', 'Yellow', 'VS1'),
(17, 'Diamond', 'Fancy intense', 'None', 'Yellow', 'VVS2'),
(18, 'Diamond', 'Fancy light', 'None', 'Blue', 'VS2'),
(19, 'Diamond', 'Fancy', 'Brownish', 'Yellow', 'VS1'),
(20, 'Diamond', 'Fansy Vivid', 'None', 'Yellow', 'VVS1'),
(21, 'Diamond', 'Light', 'None', 'Blue', 'VS2'),
(22, 'Diamond', 'Fancy Deep', 'None', 'Yellow', 'VS1'),
(23, 'Diamond', 'Fancy', 'Greenish', 'Yellow', 'VVS2'),
(24, 'Diamond', 'Fancy intense', 'None', 'Orange', 'VS1'),
(25, 'Diamond', 'Fancy', 'None', 'Yellow', 'VS2');


-- Rubies
INSERT INTO colored_gem_stone (lot_id, gem_type, gem_color, treatment) VALUES
(26, 'Ruby', 'Red', 'heated'),
(27, 'Ruby', 'Pigeon blood', 'No heat'),
(28, 'Ruby', 'Red', 'heated'),
(29, 'Ruby', 'Pigeon blood', 'No heat'),
(30, 'Ruby', 'Red', 'heated'),
(31, 'Ruby', 'Pigeon blood', 'No heat'),
(32, 'Ruby', 'Red', 'heated'),
(33, 'Ruby', 'Pigeon blood', 'No heat');

-- Sapphires
INSERT INTO colored_gem_stone (lot_id, gem_type, gem_color, treatment) VALUES
(34, 'Sapphire', 'Royal Blue', 'No heat'),
(35, 'Sapphire', 'Blue', 'heated'),
(36, 'Sapphire', 'Royal Blue', 'No heat'),
(37, 'Sapphire', 'Blue', 'heated'),
(38, 'Sapphire', 'Royal Blue', 'No heat'),
(39, 'Sapphire', 'Blue', 'heated'),
(40, 'Sapphire', 'Royal Blue', 'No heat'),
(41, 'Sapphire', 'Blue', 'heated');

-- Emeralds
INSERT INTO colored_gem_stone (lot_id, gem_type, gem_color, treatment) VALUES
(42, 'Emerald', 'Green', 'Minor Oil'),
(43, 'Emerald', 'Green', 'No oil'),
(44, 'Emerald', 'Green', 'Oiled'),
(45, 'Emerald', 'Green', 'No oil'),
(46, 'Emerald', 'Green', 'Minor Oil'),
(47, 'Emerald', 'Green', 'Oiled');


INSERT INTO jewelry (lot_id, jewelry_type, gross_weight_gr, metal_type, metal_weight_gr,
                     total_center_stone_qty, total_center_stone_weight_ct, centered_stone_type,
                     total_side_stone_qty, total_side_stone_weight_ct, side_stone_type) VALUES
(48, 'Ring', 5.82, 'PT950', 4.25, 1, 1.52, 'White Diamond', 16, 0.48, 'White Diamond'),
(49, 'Necklace', 18.45, '18k white gold', 15.20, 1, 2.85, 'Emerald', 42, 1.25, 'White Diamond'),
(50, 'Earrings', 8.92, 'PT900', 6.35, 2, 1.85, 'White Diamond', 28, 0.72, 'White Diamond'),
(51, 'Ring', 6.15, '18k white gold', 4.58, 1, 3.25, 'Sapphire', 18, 0.55, 'White Diamond'),
(52, 'Bracelet', 22.35, '18k rose gold', 18.90, 7, 3.45, 'Ruby', 0, 0.00, 'None'),
(53, 'Brooch', 12.68, 'PT950', 9.85, 1, 2.15, 'Emerald', 35, 1.08, 'White Diamond'),
(54, 'Ring', 5.45, '18k white gold', 3.95, 1, 1.95, 'White Diamond', 12, 0.36, 'White Diamond'),
(55, 'Necklace', 25.75, '18k white/yellow gold', 21.50, 1, 4.25, 'Sapphire', 58, 1.85, 'White Diamond'),
(56, 'Earrings', 7.35, 'PT900', 5.20, 2, 1.28, 'Ruby', 24, 0.58, 'White Diamond'),
(57, 'Ring', 6.88, 'PT950', 5.12, 1, 2.45, 'White Diamond', 20, 0.62, 'White Diamond'),
(58, 'Bracelet', 19.45, '18k white gold', 16.20, 5, 2.75, 'Diamond', 0, 0.00, 'None'),
(59, 'Necklace', 21.88, 'PT950', 17.95, 1, 3.58, 'Emerald', 48, 1.48, 'White Diamond'),
(60, 'Ring', 5.95, '18k white gold + PT', 4.35, 1, 1.75, 'White Diamond', 14, 0.42, 'White Diamond');


INSERT INTO action (action_id, from_counterpart_id, to_counterpart_id, terms, remarks, created_at, updated_at) VALUES
-- Purchases from diamond suppliers
(1, 5, 1, 'Payment: 30 days net', 'White diamonds from Antwerp', '2024-01-15 10:00:00+00', '2024-01-15 10:00:00+00'),
(2, 6, 2, 'Payment: 60 days net', 'Premium Indian diamonds', '2024-02-05 09:15:00+00', '2024-02-05 09:15:00+00'),
(3, 9, 2, 'Payment: 45 days net', 'Thai rubies, high quality', '2024-01-18 09:30:00+00', '2024-01-18 09:30:00+00'),
(4, 11, 2, 'Payment: 30 days net', 'Kashmir sapphires, rare collection', '2024-01-22 10:15:00+00', '2024-01-22 10:15:00+00'),
(5, 10, 1, 'Payment: 60 days net', 'Colombian emeralds, AA grade', '2024-02-01 11:20:00+00', '2024-02-01 11:20:00+00');

-- Sales to clients
INSERT INTO action (action_id, from_counterpart_id, to_counterpart_id, terms, remarks, created_at, updated_at) VALUES
(6, 1, 13, 'Payment: Upon delivery', 'Premium engagement ring order', '2024-03-15 14:00:00+00', '2024-03-15 14:00:00+00'),
(7, 3, 14, 'Payment: 15 days net', 'Luxury jewelry collection', '2024-04-10 11:30:00+00', '2024-04-10 11:30:00+00'),
(8, 2, 15, 'Payment: Upon delivery', 'Special order sapphire pieces', '2024-05-05 10:45:00+00', '2024-05-05 10:45:00+00');


INSERT INTO purchase (action_id, purchase_num, purchase_date) VALUES
(1, 'PO-2024-0001', '2024-01-15'),
(2, 'PO-2024-0002', '2024-02-05'),
(3, 'PO-2024-0003', '2024-01-18'),
(4, 'PO-2024-0004', '2024-01-22'),
(5, 'PO-2024-0005', '2024-02-01');


-- White diamonds from Antwerp
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code) VALUES
(1, 1, 1, 18500.00, 'USD'),
(1, 2, 1, 32000.00, 'USD'),
(1, 3, 1, 19200.00, 'USD'),
(1, 6, 1, 8700.00, 'USD'),
(1, 7, 1, 14900.00, 'USD'),
(1, 12, 1, 17900.00, 'USD'),
(1, 13, 1, 9000.00, 'USD'),
(1, 14, 1, 14800.00, 'USD'),
(1, 15, 1, 9900.00, 'USD');

-- Diamonds from Mumbai
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code) VALUES
(2, 4, 1, 52000.00, 'USD'),
(2, 5, 1, 13500.00, 'USD'),
(2, 8, 1, 28800.00, 'USD'),
(2, 9, 1, 16500.00, 'USD'),
(2, 10, 1, 25100.00, 'USD'),
(2, 11, 1, 15500.00, 'USD');

-- Rubies from Bangkok
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code) VALUES
(3, 26, 1, 28500.00, 'USD'),
(3, 27, 1, 58000.00, 'USD'),
(3, 28, 1, 18900.00, 'USD'),
(3, 29, 1, 11000.00, 'USD'),
(3, 30, 1, 20100.00, 'USD'),
(3, 31, 1, 10400.00, 'USD'),
(3, 32, 1, 8100.00, 'USD'),
(3, 33, 1, 17500.00, 'USD');

-- Sapphires from Kashmir
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code) VALUES
(4, 34, 1, 45000.00, 'USD'),
(4, 35, 1, 28000.00, 'USD'),
(4, 36, 1, 33000.00, 'USD'),
(4, 37, 1, 58000.00, 'USD'),
(4, 38, 1, 55000.00, 'USD'),
(4, 39, 1, 11000.00, 'USD'),
(4, 40, 1, 34000.00, 'USD'),
(4, 41, 1, 20000.00, 'USD');

-- Emeralds from Colombia
INSERT INTO action_item (action_id, lot_id, quantity, unit_price, currency_code) VALUES
(5, 42, 1, 32500.00, 'USD'),
(5, 43, 1, 52000.00, 'USD'),
(5, 44, 1, 18000.00, 'USD'),
(5, 45, 1, 28000.00, 'USD'),
(5, 46, 1, 24000.00, 'USD'),
(5, 47, 1, 38000.00, 'USD');


INSERT INTO sale (action_id, sale_num, sale_date, payment_method, payment_status) VALUES
(6, 'SO-2024-0001', '2024-03-15', 'Wire Transfer', 'Paid'),
(7, 'SO-2024-0002', '2024-04-10', 'Credit Card', 'Partial paid'),
(8, 'SO-2024-0003', '2024-05-05', 'Wire Transfer', 'Unpaid');


INSERT INTO certificate (lot_id, lab_id, certificate_num, issue_date, shape, weight_ct, length, width, depth, clarity, gem_type) VALUES
-- White Diamond Certificates (GIA)
(1, 17, 'GIA-2145678901', '2024-01-20 10:00:00+00', 'Brilliant Cut', 1.52, 7.45, 7.42, 4.58, 'VS1', 'Diamond'),
(2, 17, 'GIA-2145678902', '2024-01-25 14:30:00+00', 'Brilliant Cut', 2.03, 8.15, 8.12, 5.02, 'VVS2', 'Diamond'),
(3, 17, 'GIA-2145678903', '2024-01-25 14:30:00+00', 'Princess',      0.75, 5.32, 5.29, 3.88, 'VS2', 'Diamond'),
(4, 17, 'GIA-2145678904', '2024-02-15 11:00:00+00', 'Emerald Cut',   3.21, 10.12, 8.05, 5.67, 'VVS1', 'Diamond'),
(5, 17, 'GIA-2145678905', '2024-02-15 11:00:00+00', 'Brilliant Cut', 1.08, 6.58, 6.55, 4.05, 'VS1', 'Diamond'),
(6, 17, 'GIA-2145678906', '2024-02-15 11:00:00+00', 'Oval',          2.54, 9.85, 7.32, 4.95, 'IF', 'Diamond'),
(7, 17, 'GIA-2145678907', '2024-02-15 11:00:00+00', 'Pear Shape',    0.92, 7.12, 5.48, 3.45, 'VS2', 'Diamond'),
(8, 17, 'GIA-2145678908', '2024-02-15 11:00:00+00', 'Brilliant Cut', 1.75, 7.85, 7.82, 4.82, 'VVS2', 'Diamond'),
(9, 17, 'GIA-2145678909', '2024-04-05 15:20:00+00', 'Brilliant Cut', 4.15, 10.58, 10.55, 6.52, 'FL', 'Diamond'),
(10, 17, 'GIA-2145678910', '2024-04-05 15:20:00+00', 'Princess',     1.32, 6.25, 6.22, 4.32, 'VS1', 'Diamond'),
(11, 17, 'GIA-2145678911', '2024-04-05 15:20:00+00', 'Brilliant Cut',0.58, 5.28, 5.25, 3.25, 'VS2', 'Diamond'),
(12, 17, 'GIA-2145678912', '2024-04-05 15:20:00+00', 'Radiant Cut',  2.88, 8.95, 8.12, 5.35, 'VVS1', 'Diamond'),
(13, 17, 'GIA-2145678913', '2024-04-05 15:20:00+00', 'Brilliant Cut',1.95, 8.05, 8.02, 4.95, 'VS1', 'Diamond'),
(14, 17, 'GIA-2145678914', '2024-05-28 09:45:00+00', 'Oval',         3.42, 11.25, 8.45, 5.78, 'VVS2', 'Diamond'),
(15, 17, 'GIA-2145678915', '2024-05-28 09:45:00+00', 'Heart Shape',  1.18, 7.05, 6.98, 4.15, 'VS2', 'Diamond'),

-- Colored Diamond Certificates (IGI)
(16, 18, 'IGI-456789116', '2024-02-18 13:00:00+00', 'Brilliant Cut', 1.85, 7.92, 7.89, 4.88, 'VS1', 'Diamond'),
(17, 18, 'IGI-456789117', '2024-02-18 13:00:00+00', 'Radiant Cut', 2.34, 8.45, 7.58, 4.92, 'VVS2', 'Diamond'),
(18, 18, 'IGI-456789118', '2024-02-18 13:00:00+00', 'Princess', 0.88, 5.68, 5.65, 3.95,'VS2', 'Diamond'),
(19, 18, 'IGI-456789119', '2024-02-18 13:00:00+00', 'Oval', 1.52, 8.15, 6.32, 4.25, 'VS1', 'Diamond'),
(20, 18, 'IGI-456789120', '2024-02-18 13:00:00+00', 'Brilliant Cut', 3.15, 9.85, 9.82, 6.08,'VVS1', 'Diamond'),
(21, 18, 'IGI-456789121', '2024-02-18 13:00:00+00', 'Pear Shape', 1.05, 7.45, 5.82, 3.68, 'VS2', 'Diamond'),
(22, 18, 'IGI-456789122', '2024-02-18 13:00:00+00', 'Brilliant Cut', 2.08, 8.25, 8.22, 5.08, 'VS1', 'Diamond'),
(23, 18, 'IGI-456789123', '2024-02-18 13:00:00+00', 'Radiant Cut', 1.42, 7.35, 6.82, 4.45, 'VVS2', 'Diamond'),
(24, 18, 'IGI-456789124', '2024-02-18 13:00:00+00', 'Oval', 2.75, 9.45, 7.25, 4.88, 'VS1', 'Diamond'),
(25, 18, 'IGI-456789125', '2024-02-18 13:00:00+00', 'Brilliant Cut', 1.68, 7.75, 7.72, 4.78, 'VS2', 'Diamond'),

-- Ruby Certificates (HRD)
(26, 19, 'HRD-789123426', '2024-02-12 14:00:00+00', 'Oval', 2.45, 8.85, 6.75, 4.52, NULL, 'Ruby'),
(27, 19, 'HRD-789123427', '2024-02-12 14:00:00+00', 'Oval', 3.82, 10.25, 8.15, 5.35, NULL, 'Ruby'),
(28, 19, 'HRD-789123428', '2024-02-12 14:00:00+00', 'Oval', 1.68, 7.95, 6.05, 4.08, NULL, 'Ruby'),
(29, 19, 'HRD-789123429', '2024-04-10 11:30:00+00', 'Oval', 5.12, 11.85, 9.25, 6.15, NULL, 'Ruby'),
(30, 19, 'HRD-789123430', '2024-02-12 14:00:00+00', 'Oval', 2.95, 9.35, 7.45, 4.88, NULL, 'Ruby'),
(31, 19, 'HRD-789123431', '2024-05-18 15:45:00+00', 'Oval', 4.25, 10.95, 8.85, 5.75, NULL, 'Ruby'),
(32, 19, 'HRD-789123432', '2024-02-12 14:00:00+00', 'Oval', 1.92, 8.15, 6.35, 4.25, NULL, 'Ruby'),
(33, 19, 'HRD-789123433', '2024-02-12 14:00:00+00', 'Oval', 3.45, 10.05, 7.95, 5.25, NULL, 'Ruby'),

-- Sapphire Certificates (GIA)
(34, 17, 'GIA-3156789034', '2024-01-28 12:00:00+00', 'Oval', 3.15, 9.75, 7.85, 5.12, NULL, 'Sapphire'),
(35, 17, 'GIA-3156789035', '2024-01-28 12:00:00+00', 'Oval', 2.28, 8.65, 6.95, 4.55, NULL, 'Sapphire'),
(36, 17, 'GIA-3156789036', '2024-03-12 16:20:00+00', 'Oval', 4.52, 11.15, 9.05, 5.98, NULL, 'Sapphire'),
(37, 17, 'GIA-3156789037', '2024-01-28 12:00:00+00', 'Oval', 1.85, 8.05, 6.45, 4.22, NULL, 'Sapphire'),
(38, 17, 'GIA-3156789038', '2024-05-15 10:50:00+00', 'Oval', 5.35, 12.25, 9.85, 6.48, NULL, 'Sapphire'),
(39, 17, 'GIA-3156789039', '2024-01-28 12:00:00+00', 'Oval', 2.75, 9.15, 7.35, 4.82, NULL, 'Sapphire'),
(40, 17, 'GIA-3156789040', '2024-01-28 12:00:00+00', 'Oval', 3.88, 10.45, 8.45, 5.58, NULL, 'Sapphire'),
(41, 17, 'GIA-3156789041', '2024-01-28 12:00:00+00', 'Oval', 2.05, 8.35, 6.65, 4.38, NULL, 'Sapphire'),

-- Emerald Certificates (AGS)
(42, 20, 'AGS-123456742', '2024-03-20 13:30:00+00', 'Emerald Cut', 2.85, 9.25, 7.15, 5.05, NULL, 'Emerald'),
(43, 20, 'AGS-123456743', '2024-03-20 13:30:00+00', 'Emerald Cut', 3.95, 10.65, 8.25, 5.85, NULL, 'Emerald'),
(44, 20, 'AGS-123456744', '2024-03-20 13:30:00+00', 'Emerald Cut', 1.75, 7.85, 6.05, 4.35, NULL, 'Emerald'),
(45, 20, 'AGS-123456745', '2024-05-08 09:15:00+00', 'Emerald Cut', 4.58, 11.45, 8.95, 6.28, NULL, 'Emerald'),
(46, 20, 'AGS-123456746', '2024-03-20 13:30:00+00', 'Emerald Cut', 2.35, 8.75, 6.75, 4.75, NULL, 'Emerald'),
(47, 20, 'AGS-123456747', '2024-03-20 13:30:00+00', 'Emerald Cut', 3.28, 9.95, 7.75, 5.48, NULL, 'Emerald');

INSERT INTO action (action_id, from_counterpart_id, to_counterpart_id, terms, remarks, created_at, updated_at) VALUES
(9, 1, 13, 'Return within 14 days', 'Client review - engagement ring selection', '2024-02-10 10:00:00+00', '2024-02-10 10:00:00+00'),
(10, 2, 15, 'Return within 7 days', 'Client approval for custom necklace', '2024-03-15 14:30:00+00', '2024-03-15 14:30:00+00');

INSERT INTO memo_out (action_id, memo_out_num, ship_date, expected_return_date) VALUES
(9, 'MO-2024-0001', '2024-02-10', '2024-02-24'),
(10, 'MO-2024-0002', '2024-03-15', '2024-03-22');


INSERT INTO action_update_log (log_time, action_id, employee_id, update_type, old_value, new_value) VALUES
('2024-01-15 10:00:00+00', 1, 1, 'Insert', NULL, NULL),
('2024-01-15 14:30:00+00', 1, 4, 'Update', '{"status": "pending"}', '{"status": "approved", "approver": "Emily Brown"}'),
('2024-01-15 10:00:00+00', 2, 1, 'Insert', NULL, NULL),
('2024-01-15 10:00:00+00', 3, 1, 'Insert', NULL, NULL),
('2024-01-15 10:00:00+00', 4, 1, 'Insert', NULL, NULL),
('2024-01-15 10:00:00+00', 5, 1, 'Insert', NULL, NULL),
('2024-03-15 14:00:00+00', 6, 3, 'Insert', NULL, NULL),
('2024-03-15 16:00:00+00', 6, 1, 'Update', '{"payment_status": "Unpaid"}', '{"payment_status": "Paid", "payment_date": "2024-03-15"}'),
('2024-01-15 10:00:00+00', 7, 1, 'Insert', NULL, NULL),
('2024-01-15 10:00:00+00', 8, 1, 'Insert', NULL, NULL),
('2024-01-15 10:00:00+00', 9, 1, 'Insert', NULL, NULL),
('2024-01-15 10:00:00+00', 10, 1, 'Insert', NULL, NULL);

-- ROLLBACK;
COMMIT;

-- Display summary
SELECT COUNT(*) AS total_items FROM item;
SELECT COUNT(*) AS total_loose_stones FROM loose_stone;
SELECT COUNT(*) AS total_jewelry FROM jewelry;
SELECT COUNT(*) AS total_actions FROM action;
SELECT COUNT(*) AS total_certificates FROM certificate;