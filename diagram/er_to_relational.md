### Relational schema (work in progress)

#### `counterpart`

counterpart (**counterpart_id**, name, phone_number, address_short, city, postal_code, country, email)

---


#### `action`

action (**action_id**, unit_price, terms, remarks, creation_date, last_update)

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



