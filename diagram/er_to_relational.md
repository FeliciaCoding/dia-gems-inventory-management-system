## Relational schema


### `currency`
currency (**code**, name)

---


### `counterpart`

counterpart (**counterpart_id**, name, phone_number, address_short, city, postal_code, country, email, is_active, created_at, updated_at)


account_type (**type_name**, category, is_internal)
    

counterpart_account_type (**counterpart_id, type_name**) <br>
    `counterpart_id` references `counterpart.counterpart_id` <br>
    `type_name` references `account_type.type_name`

---

### `employee`

employee (**employee_id**, counterpart_id, first_name, last_name, email, role, is_active, created_at, updated_at) <br>
    `counterpart_id` references `counterpart.counterpart_id` NOT NULL

---

### `action`

action (**action_id**, from_counterpart_id, to_counterpart_id, terms, remarks, created_at, updated_at) <br>
    `from_counterpart_id` references `counterpart.counterpart_id` NOT NULL <br>
    `to_counterpart_id` references `counterpart.counterpart_id` NOT NULL <br>
    
---

### `action_update_log`

update_log (**log_sequence, action_id**, employee_id, update_type, old_value, new_value, log_time) <br>
    `action_id` references `action.action_id` <br>
    `employee_id` references `employee.employee_id` NOT NULL

---

### `item`

item (**lot_id**, stock_name, purchase_date, supplier_id, origin, responsible_office_id, created_at, updated_at, is_available) <br>
    `supplier_id` references `counterpart.counterpart_id` NOT NULL
    `responsible_office_id` references `counterpart.counterpart_id` NOT NULL


action_item(**action_id, lot_id**, quantity, unit_price, currency_code) <br>
   `action_id` references `action.action_id` <br>
   `lot_id` references `item.lot_id` <br>
   `currency_code` references `currency.code` NOT NULL


---

### Actions

purchase(**action_id**, purchase_num, purchase_date) <br>
    `action_id` references `action.action_id`


memo_in (**action_id**, memo_in_num, ship_date, expected_return_date) <br>
    `action_id` references `action.action_id`


return_memo_in (**action_id**, orig_memo_in_action_id, return_memo_in_num, back_date) <br>
    `action_id` references `action.action_id` <br>
    `orig_memo_action_id` references `memo_in.action_id` NOT NULL


return_memo_in_items( **action_id, lot_id**, notes) <br>
    `action_id` references `return_memo_in.action_id` <br>
    `lot_id` references `item.lot_id`


memo_out(**action_id**, memo_out_num, ship_date, expected_return_date) <br>
    `action_id` references `action.action_id`


return_memo_out(**action_id**, orig_memo_action_id, return_memo_out_num, back_date) <br>
    `action_id` references `action.action_id` <br>
    `orig_memo_action_id` references `memo_out.action_id` NOT NULL


return_memo_out_items (**action_id, lot_id**, notes) <br>
    `action_id` references `return_memo_out.action_id` <br>
    `lot_id` references `item.lot_id`


transfer_to_office(**action_id**, transfer_num, ship_date) <br>
    `action_id` references `action.action_id`


transfer_to_lab(**action_id**, transfer_num, ship_date) <br>
    `action_id` references `action.action_id`


back_from_lab(**action_id**, orig_transfer_id, back_from_lab_num, back_date)  <br>
    `action_id` references `action.action_id` <br>
    `orig_transfer_id` references `transfer_to_lab.action_id` NOT NULL


back_from_lab_items (**action_id, lot_id**, notes) <br>
    `action_id` references `back_from_lab.action_id` <br>
    `lot_id` references `item.lot_id`


transfer_to_factory(**action_id**, transfer_num, ship_date) <br>
    `transfer_to_factory.action_id` references `action.action_id`


back_from_factory(**action_id**, orig_transfer_id, back_from_fac_num, back_date) <br>
    `action_id` references `action.action_id` <br>
    `orig_transfer_id` references `transfer_to_factory.action_id` NOT NULL


back_from_factory_details(**action_id, lot_id**, after_weight_ct, after_shape, after_length, after_width, after_depth, weight_loss_ct, note) <br>
    `action_id` references `back_from_factory.action_id` <br>
    `lot_id` references `item.lot_id`


sale(**action_id**, sale_num, sale_date, payment_method, payment_status) <br>
    `action_id` references `action.action_id`

---

## `item` (continue)


loose_stone (**lot_id**, weight_ct, shape, length, width, depth) <br>
    `lot_id` references `item.lot_id`


white_diamond (**lot_id**, white_level, clarity) <br>
    `lot_id` references `loose_stone.lot_id`


colored_diamond (**lot_id**, gem_type, fancy_intensity, fancy_overton, fancy_color, clarity) <br>
    `lot_id` references `loose_stone.lot_id`


colored_gem_stone (**lot_id**, gem_type, shape, gem_color, treatment) <br>
    `lot_id` references `loose_stone.lot_id`


jewelry (**lot_id**, jewerly_type, gross_weight_gr, metal_type, metal_weight_gr,
total_center_stone_qty, total_center_stone_weight_ct, centered_stone_type,
total_side_stone_qty, total_side_stone_weight_ct, side_stone_type)  <br>
    `lot_id` references `item.lot_id`


---


### `certificate`

certificate(**certificate_id**, lot_id, lab_id, certificate_num, issue_date, shape, weight_ct, length, width, depth, clarity, color, treatment, gem_type, created_at, updated_at) <br>
    `lot_id` references `item.lot_id` NOT NULL <br>
    `lab_id` references `counterpart.counterpart_id` NOT NULL


