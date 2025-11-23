### Relational schema (work in progress)

#### `counterpart`

counterpart (**counterpart_id**, name, phone_number, address_short, city, postal_code, country, email)

account_type (**type_name**, category, is_internal)

counterpart_account_type (**counterpart_id**, **type_name**)
    counterpart_id references counterpart.counterpart_id
    type_name references account_type.type_name

---

#### `employee`
employee (**employee_id**, first_name, last_name, email, role, is_active)

update_log (**log_id**, action_id, employee_id, update_type, log_time)
    action_id references action.action_id 
    employee_id references employee.employee_id

---


#### `action`

action (**action_id**, terms, remarks, creation_date, last_update)

counterpart_action (**from_counterpart_id, to_counterpart_id, action_id**)
    from_counterpart_id references counterpart.counterpart_id
    to_counterpart_id references counterpart.counterpart_id
    action_id references action.action_id

purchase(**action_id**, purchase_num)
    purchase.action_id references action.action_id

memo_in (**action_id**, memo_in_num, ship_date)
    memo_in.action_id references action.action_id

return_memo_in (**action_id, return_memo_in_num**, back_date)
    action_id references memo_in.action_id

return_memo_in_details( **return_action_id, return_memo_in_num, return_line_no**, memo_in_action_id, memo_in_line_no, qty_returned)
    (return_action_id, return_memo_in_num)  references (return_memo_in.action_id, return_memo_in.memo_in_num)
    memo_in_action_id references memo_in.action_id
    (memo_in_action_id,memo_in_line_no)  references (action_item.action_id, action_item.line_no)

memo_out(**action_id**, memo_out_num, ship_date )
    action_id references action.action_id

return_memo_out(**action_id, return_memo_out_num**, back_date)
    action_id REFERENCES memo_out.action_id

return_memo_out_details( **return_action_id, return_memo_out_num, return_line_no**, memo_out_action_id, memo_out_line_no, qty_returned)
    (return_action_id, return_memo_out_num) references (return_memo_out.action_id, return_memo_out.return_memo_out_num)
    memo_out_action_id references memo_out.action_id
    (memo_out_action_id, memo_out_line_no) references (action_item.action_id, action_item.line_no)
    
transfer_to_office(**action_id**, transfer_num, ship_date)
    action_id references action.action_id

transfer_to_lab(**action_id**, transfer_num, ship_date)
    action_id references action.action_id

back_from_lab(**action_id, back_from_lab_num**, back_date)
    action_id REFERENCES transfer_to_lab.action_id

back_from_lab_details(**return_action_id,back_from_lab_num, return_line_no**, send_action_id, send_line_no, qty_returned)
    (return_action_id, back_from_lab_num) references (back_from_lab.action_id, back_from_lab.back_from_lab_num)
    send_action_id references transfer_to_lab.action_id
    (send_action_id, send_out_line_no) references (action_item.action_id, action_item.line_no)

```
to be completed
```

---


#### `item`

item (**lot_id**, stock_name,
      purchase_date, supplier, sale_unit, cost_unit, origin)


loose_stone (**lot_id**, weight_ct, length, width, depth)
    loose_stone.lot_id references item.lot_id

white_diamond (**lot_id**, white_level, shape, clarity)
    white_diamond.lot_id references loose_stone.lot_id

colored_diamond (**lot_id**, gem_type, fancy_intensity, fancy_overton, fancy_color, shape, clarity)
    colored_diamond.lot_id references loose_stone.lot_id

colored_gem_stone (**lot_id**, gem_type, shape, color, treatment, origin)
    colored_gem_stone.lot_id references loose_stone.lot_id

jewerly (**lot_id**, jew_type, gross_weight_gr, metal_type, metal_weight_gr,
    total_center_stone_qty, total_center_stone_weight_ct, centered_stone_type,
    total_side_stone_qty, total_side_stone_weight_ct, side_stone_type)
    jewerly.lot_id references item.lot_id

action_item(**action_id,lot_id**, line_no, qty, unit_price,currency_code)
   action_id references action.action_id
   lot_id references item.lot_id
   currency_code references currency.currency_code
   (action_id, line_no) is unique
    

---

### `currency`
currency (**code**, name)

---

### `certificate`

certificate(**certificate_id**, lab_id, issue_date, shape, weight_ct,
            length, width, depth, clarity, color, treatment, gem_type)
    certificate.lab_id references counterpart.counterpart_id



