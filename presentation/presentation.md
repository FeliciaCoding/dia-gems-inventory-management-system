---
theme: default
_class: lead
paginate: true
backgroundColor: #fff
---

# Inventory management system for diamonds, colored stones, and jewelries

![width:700px](img/intro_diamond_track.png)

## Authors: Liao Pei-Wen, Makovskyi Maksym, Guo Yu Wu

---

# What problem we are trying to solve ?

Companies in the diamond and precious stone sector face several operational challenges:

- Paper-based processes that create delays and errors.
- Fragmented spreadsheets create duplicates, slow searches, and inventory errors.
- Limited traceability (certificates, provenance) increases audit and compliance risk.

---

# Conceptual schema (1)

action inheretance  
![width:700px](img/e_zones.png)

- red : central table : action
- blue : counterPart, person
- green : items, merchandising
- yellow : docs, certificate

---

# Conceptual schema (1)

action inheretance  
![width:700px](img/action_table.png)

--- 

# Conceptual schema (2)

item inheretance

---

# Conceptual schema (3)

Return style actions

---

# Conceptual schema (4)

Link between Action and Item  
![width:700px](img/action_item.png)


---

# Conceptual schema (5)

Link between Counterpart and Account type

---

# Conceputal schema (6)

Employee and Action

---

# Certificate

Certificate

---

# Relation schema (1)

Item inheretance transaltion

---

# Relation schema (2)

Action inheretance transaltion

---

# Relation schema (3)

Return style actions

---

# Relation schema (4)

ActionItem relation

---

# Relation schema (5)

Employee and Action

---

# Relation schema (6)

Counterpart and Account Type

---

# Relation schema (7)

Certificate

---

# SQL (1)

View to look at some type of inventory

--- 

# SQL (2)

View to look at the inventory by type

---

# SQL (3)

Trigger 1 to keep tract availability and location

---

# SQL (4)

Trigger 7 to check what items are being returned

---

# SQL (5)

Trigger 11 to invalidate the certificates after return from fac

---

# SQL (6)

Make a purchase procedure

---

# SQL (7)

Find all availible items at office

`database.item.item.py:get_items_stored_in_office`

---

# Tech stack

- Frontend: Streamlit
- Database: PostgreSQL 18
- Python: 3.13
- Package Manager: uv
- Container: Docker

---

<br>

# Demo

---

# Challanges

- Design document to Conceptual schema
- UI design (what a person who is going to be use it will need)
- Correcting item's data when item has undergone at least one action
- Correcting action's data if the it isn't the most recent action

---

# Implemented (or not) features

List of most important stuff

---

# Conclusion

- Modeling data is hard
- Processe in real life can have many little twists and caveats
- Conceptual (ER) phase maybe is the most important phase in the project

---

<br>

# Thank you for your attention !

