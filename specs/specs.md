# Inventory Management Tool For Diamond/ Precious Stones

#####
member:  Liao Pei-Wen, Maksym Makovskyi, Wu Guo Yu


## Introduction :

### Product :
The proposed system is a secure inventory management and traceability platform dedicated to diamonds, colored stones, and jewelry.
It acts as a centralized and reliable source of information for identifying, tracking, and managing goods throughout their lifecycle.

### Business Problem:
- Paper-based processes (purchase notes, memos, transfers, invoices) create delays and errors.
- Fragmented spreadsheets create duplicates, slow searches, and inventory errors.
- Limited traceability (certificates, provenance) increases audit and compliance risk.

### Goal :
The objective of this project is to design an inventory management system that:
- End-to-end traceability with controlled, auditable state transitions.
- Faster operations from receiving to certification to listing; fewer variances; higher inventory turns.

---

## User profile :

- **Company type :** Colored stones / Dimond Dealer in B2B
- **Geographical scope:** worldwide
- **Language :** English

### User roles:
- **Chief :** Full access to all system data and functionalities
- **Administrator :** Tracking goods' overall status, generating inventory list, following shipment
- **Sales :** Requires fast and accurate access to up-to-date inventory information
- **Accountant :** Handle AR/AP and reconsiliation. Need consistent documents, clean links between goods and invoice + reliable exports/ import.

---
## Analysis of Data needs

The company manages high-value inventory composed of **diamonds**, **gemstones**, and **jewelry**.
Each physical item is managed individually in order to ensure precise traceability and certification control.
Although this project models a single company, the system must support operations across **multiple offices** and interactions with **external partners**, including suppliers, laboratories, and manufacturers.

### Lot Concept
Each physical inventory unit is managed as a **Lot**.
A lot represents **exactly one physical object**:
- either a **single diamond or gemstone**, or
- a **single piece of jewelry**.

Each lot is uniquely identified within the system and associated with a stock reference.
Lots are not grouped or batched.

Each lot is characterized by:
- A controlled **status**, belonging to a predefined and validated set of states
- A current **location**, which may be an internal office or an external partner
- An **item category** (diamond, gemstone, or jewelry)
- A **purchase date** and, when applicable, a **sale date**
- A linked **counterparty** (supplier, client, laboratory, or manufacturer)
- Financial information, including cost and sale valuation when applicable

Financial information is not stored directly on the lot.
Prices and currencies are associated with a lot only through commercial documents such as purchases or sales.

---

## Product-Specific Characteristics

- **Diamond lots** are described using gemological attributes such as shape, color characteristics (including white or fancy color scales), clarity, possible origin, and physical dimensions.
  A diamond lot may be associated with **one or more laboratory certificates**, allowing for re-certification while preserving historical records.


- **Gemstone lots** include information such as gem type, shape, color, treatment, possible origin, and physical dimensions.
  Certification information may be associated when available.


- **Jewelry lots** describe a single finished or semi-finished jewelry piece.
  They include jewelry type, composition of center and side stones (types, quantities, and weights), metal type, metal weight, and gross weight.
  Jewelry lots may reference associated stones for traceability purposes.

---

## Parties and Users

The system manages several types of parties involved in inventory operations:
- **Suppliers**
- **Clients**
- **Offices**
- **Service partners**, such as laboratories and manufacturers

Each party stores legal identification data, contact information, and operational references required for business transactions.

User accounts are defined by roles (Chief, Administrator, Sales, Accountant).
Users may be associated with a specific office or party in order to determine access rights and operational responsibilities.

---

### Inventory Lifecycle


The lifecycle of each lot is driven by business documents that represent real-world operations:

![workFlow.png](img/workFlow.png)

- A **Purchase Note** records the acquisition of goods from a supplier and introduces owned goods into inventory.


- A **Memo In** records goods received on consignment, where ownership remains with the counterparty.


- A **Return Memo In** records the return of consigned goods to the counterparty while preserving traceability.


- A **Memo Out** records goods sent to a client or partner for approval, during which the goods are not available for sale.


- A **Return Memo Out** records the return of goods previously sent on approval, restoring their availability.


- A **Transfer** records the movement of goods between offices or external partners for processing or services such as certification or recutting.


- A **Return Transfer** records the receipt of goods following external processing and may result in updated characteristics or certification.


- An **Invoice** confirms a sale, transfers ownership to the client, and closes the commercial lifecycle of the lot.

---
## Traceability and Validation

All inventory movements and state changes are fully traceable.
For each operation, the system preserves historical information allowing reconstruction of:
- Status changes
- Location changes
- Responsible users
- Operational context

To ensure consistency and validation, controlled value lists are maintained for key attributes such as statuses, shapes, colors, clarity levels, treatments, laboratories, and other reference data.

