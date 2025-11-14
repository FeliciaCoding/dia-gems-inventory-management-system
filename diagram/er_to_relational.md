### Work in progress
Counterpart (**counterpart_id**, name, phone_number, address_short, city, postal_code, country, email)

Action (**action_id**, unit_price, terms, remarks, creation_date, last_update)

### Few questions regarding `Action` entity

1. Should we add `Employee` entity ? 
Since for tracability it would be nice     
to see who has performed an action.
<br/>

2. What is `action_office`?
<br/>

3. Why we need `location` ? 
Action is already bounded to at least two counterparts.
So, having an information about those counterparts and 
seeing which table is being affected (`TranserToLab` for example)
we could deduce (or even more: while translating er schema to relation 
one we have to create a special table
that will represent this kind of association between two entities, 
and there will be a column for `sender_counterpart` 
and `receiver_counterpart`) that target location is the lab.
<br/>

4. What is `account` ?

```


