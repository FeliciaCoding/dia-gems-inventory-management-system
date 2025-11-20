### Relational schema (work in progress)

#### `counterpart`

counterpart (**counterpart_id**, name, phone_number, address_short, city, postal_code, country, email)

account_type (**type_name**, category, is_internal)

counterpart_account_type (**counterpart_id**, **type_id**)

---

#### `employee`
employee (**employee_id**, first_name, last_name, email, role, is_active)

update_log (**log_id**, action_id, employee_id, update_type, log_time)

---


#### `action`

action (**action_id**, terms, remarks, creation_date, last_update)

counterpart_action (**from_counterpart_id, to_counterpart_id, action_id**)


purchase_notice (**action_id**, purchase_num)
purchase_notice.action_id references action.action_id

memo_in (**action_id**, memo_in_num, ship_date)
memo_in.action_id references action.action_id

return_memo_in (**action_id**, **return_memo_in**, back_date)
return_memo_in.action_id references action.action_id



```
to be completed
```

---


#### `item`

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

jewerly (**lot_id**, jew_type, gross_weight_gr, metal_type, metal_weight_gr,
        total_center_stone_qty, total_center_stone_weight_ct, centered_stone_type,
        total_side_stone_qty, total_side_stone_weight_ct, side_stone_type)

action_item(**action_id**, **lot_id**)



