## Relational schema (work in progress)

### `counterpart`

counterpart (**counterpart_id**, name, phone_number, address_short, city, postal_code, country, email)



account_type (**type_name**, category, is_internal)

    

counterpart_account_type (**counterpart_id**, **type_name**) <br>
    `counterpart_id` references `counterpart.counterpart_id` <br>
    `type_name` references `account_type.type_name`

---

### `employee`
employee (**employee_id**, first_name, last_name, email, role, is_active)



update_log (**log_id**, action_id, employee_id, update_type, log_time) <br>
    `update_log.action_id` references `action.action_id`  <br>
    `update_log.employee_id` references `employee.employee_id` <br>
    `update_log.action_id`, `update_log.employee_id` are not null.

---


### `action`

action (**action_id**, terms, remarks, creation_date, last_update)

    

counterpart_action (**from_counterpart_id, to_counterpart_id, action_id**) <br>
    `counterpart_action.from_counterpart_id` references `counterpart.counterpart_id` <br>
    `counterpart_action.to_counterpart_id` references `counterpart.counterpart_id` <br>
    `counterpart_action.action_id` references `action.action_id`


purchase(**action_id**, purchase_num)   <br>
    `purchase.action_id` references `action.action_id`

memo_in (**action_id**, memo_in_num, ship_date) <br>
    `memo_in.action_id` references `action.action_id`

return_memo_in (**action_id**, orig_memo_in_action_id, return_memo_in_num, back_date) <br>
    `return_memo_in.action_id` references `action.action_id` <br>
    `orig_memo_action_id` references `memo_in.action_id` <br>
    `orig_memo_action_id` is not null

return_memo_in_items( **action_id**, **lot_id**, qty_returned) <br>
    `return_memo_in_items.action_id` references `return_memo_in.action_id` <br>
    `return_memo_in_items.lot_id` references `item.lot_id`

memo_out(**action_id**, memo_out_num, ship_date ) <br>
    `memo_out.action_id` references `action.action_id`


return_memo_out(**action_id**, orig_memo_action_id, return_memo_out_num, back_date) <br>
    `return_memo_out.action_id` references `action.action_id` <br>
    `orig_memo_action_id` references `memo_out.action_id`
    `orig_memo_action_id` is not null

return_memo_out_items (**action_id**, **lot_id**, qty_returned) <br>
    `return_memo_out_items.action_id` references `return_memo_out.action_id` <br>
    `return_memo_out_items.lot_id` references `item.lot_id`
    
transfer_to_office(**action_id**, transfer_num, ship_date) <br>
    `transfer_to_office.action_id` references `action.action_id`

transfer_to_lab(**action_id**, transfer_num, ship_date) <br>
    `transfer_to_lab.action_id` references `action.action_id`

back_from_lab(**action_id**, orig_transfer_id, back_from_lab_num, back_date) <br>
    `back_from_lab.action_id` references `action.action_id` <br>
    `back_from_lab.orig_transfer_id` references `transfer_to_lab.action_id` <br>
    `back_from_lab.orig_transfer_id` is not null

back_from_lab_items (**action_id**, **lot_id**, qty_returned) <br>
    `back_from_lab_items.action_id` references `back_from_lab.action_id` <br>
    `back_from_lab_items.lot_id` references `item.lot_id`


transfer_to_factory(**action_id**, transfer_num, ship_date) <br>
    `transfer_to_factory.action_id` references `action.action_id`
    
back_from_factory(**action_id**, orig_transfer_id, back_from_fac_num, back_date) <br>
    `back_from_factory.action_id` references `action.action_id` <br>
    `back_from_factory.orig_transfer_id` references `transfer_to_factory.action_id` <br>
    `back_from_factory.orig_transfer_id` is not null 

back_from_factory_items(**action_id**, **lot_id**, qty_returned) <br>
    `back_from_factory_items.action_id` references `back_from_factory.action_id` <br>
    `back_from_factory_items.lot_id` references `item.lot_id`

sale(**action_id**, sale_num) <br>
    `sale.action_id` references `action.action_id`

---


### `item`

item (**lot_id**, stock_name, status, location, item_type, qty, 
    purchase_date, sold_date, supplier, sale_unit, cost_unit, 
    cert_lab, cert_number, origin, creation_date)

loose_stone (**lot_id**, weight_ct, length, width, depth)
    loose_stone.lot_id references item.lot_id

white_diamond (**lot_id**, white_level, shape, clarity)
    white_diamond.lot_id references loose_stone.lot_id

colored_diamond (**lot_id**, gem_type, fancy_intensity, fancy_overton, fancy_color, shape, clarity)
    colored_diamond.lot_id references loose_stone.lot_id

colored_gem_stone (**lot_id**, gem_type, shape, color, treatment, origin)
    colored_gem_stone.lot_id references loose_stone.lot_id

jewelry (**lot_id**, jew_type, gross_weight_gr, metal_type, metal_weight_gr,
    total_center_stone_qty, total_center_stone_weight_ct, centered_stone_type,
    total_side_stone_qty, total_side_stone_weight_ct, side_stone_type)




action_item(**action_id,lot_id**, line_no, qty, unit_price,currency_code) <br>
   `action_item.action_id` references `action.action_id` <br>
   `action_item.lot_id` references `item.lot_id` <br>
   `currency_code` references `currency.code` <br>
   `(action_item.action_id, action_item.line_no)` is unique


---

### `currency`
currency (**code**, name)

---
### `certificate`
```
to be completed
```



