# Report - Inventory Management Tool For Diamond / Precious Stones

#####
member:  Liao Pei-Wen, Maksym Makovskyi, Wu Guo Yu

---

# Introduction / Conclusion

This project aims to develop a comprehensive inventory management system for the B2B diamond, gemstone, and jewelry trade.

Companies in the diamond and precious stone sector face several operational challenges:
- Paper-based processes (purchase notes, memos, transfers, invoices) create delays and errors.
- Fragmented spreadsheets create duplicates, slow searches, and inventory errors.
- Limited traceability (certificates, provenance) increases audit and compliance risk.

Therefore, the object of this project is to : 
- Ensure end-to-end traceability with controlled and auditable state transitions
- Improve operational efficiency from receiving to certification to listing, reducing discrepancies and increasing inventory turnover

---

# [Specification - Phase I ](../specs/specs.md)

## 1.Introduction :

### 1.1 Product :
The proposed system is a secure inventory management and traceability platform dedicated to diamonds, colored stones, and jewelry.
It acts as a centralized and reliable source of information for identifying, tracking, and managing goods throughout their lifecycle.

### 1.2 Business Problem:
- Paper-based processes (purchase notes, memos, transfers, invoices) create delays and errors.
- Fragmented spreadsheets create duplicates, slow searches, and inventory errors.
- Limited traceability (certificates, provenance) increases audit and compliance risk.

### 1.3 Goal :
The objective of this project is to design an inventory management system that:
- Ensure end-to-end traceability with controlled and auditable state transitions
- Improve operational efficiency from receiving to certification to listing, reducing discrepancies and increasing inventory turnover

---
## 2. User Profile 

### 2.1 target market :
- **Company type :** Colored stones / Dimond Dealer in B2B
- **Geographical scope:** worldwide
- **Language :** English

### 2.2 User roles:
- **Chief :** Full access to all system data and functionalities
- **Administrator :** Tracking goods' overall status, generating inventory list, following shipment
- **Sales :** Requires fast and accurate access to up-to-date inventory information
- **Accountant :** Handle AR/AP and reconsiliation. Need consistent documents, clean links between goods and invoice + reliable exports/ import.

---
## 3. Analysis of Data needs

The company manages high-value inventory composed of **diamonds**, **gemstones**, and **jewelry**.
Each physical item is managed individually in order to ensure precise traceability and certification control.
Although this project models a single company, the system must support operations across **multiple offices** and interactions with **external partners**, including suppliers, laboratories, and manufacturers.

### 3.1 Lot Concept
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
- Financial information associated with the lot through commercial documents

Financial information is not stored directly on the lot.
Prices and currencies are associated with a lot only through commercial documents such as purchases or sales. In this project, we **do not tracking the changes of market values** during the goods' life cycle.

### 3.2 Product-Specific Characteristics

- **Diamond lots** are described using gemological attributes such as shape, color characteristics (including white or fancy color scales), clarity, possible origin, and physical dimensions.
  A diamond lot may be associated with **one or more laboratory certificates**, allowing for re-certification while preserving historical records.


- **Gemstone lots** include information such as gem type, shape, color, treatment, possible origin, and physical dimensions.
  Certification information may be associated when available.


- **Jewelry lots** describe a single finished or semi-finished jewelry piece.
  They include jewelry type, composition of center and side stones (types, quantities, and weights), metal type, metal weight, and gross weight.
  Jewelry lots may reference associated stones for traceability purposes.

### 3.3 Parties and Users

The system manages several types of parties involved in inventory operations:
- **Suppliers**
- **Clients**
- **Offices**
- **Service partners**, such as laboratories and manufacturers

Each party stores legal identification data, contact information, and operational references required for business transactions.

User accounts are defined by roles (Chief, Administrator, Sales, Accountant).
Users may be associated with a specific office or party in order to determine access rights and operational responsibilities.


### 3.4 Inventory Lifecycle


The lifecycle of each lot is driven by business documents that represent real-world operations:

![workFlow.png](img/workFlow.png)

- A **Purchase Note** records the acquisition of goods from a supplier and introduces owned goods into inventory.


- A **Memo In** records goods received on consignment, where **ownership remains with the counterparty**.


- A **Return Memo In** records the return of consigned goods to the **counterparty** while preserving traceability.


- A **Memo Out** records goods sent to a **client or partner** for approval, during which the goods are **not available** for sale.


- A **Return Memo Out** records the return of goods previously sent on approval, restoring their **availability**.


- A **Transfer** records the movement of goods between **offices** or external partners for processing or services such as certification (**lab**) or recutting (**factory**).


- A **Return Transfer** records the receipt of goods between **offices** or following external processing and may result in updated characteristics or certification(**lab or factory**).


- An **Invoice** confirms a sale, transfers ownership to the client, and closes the commercial lifecycle of the lot.

---
## 4. Functional Requirements

This section describes the expected functionalities of the system.
Each functionality corresponds to a real operational need and is enforced by the system to guarantee data consistency, traceability, and reliability.

### 4.1 Inventory Management

- The system shall allow the creation of inventory records for diamonds, gemstones, and jewelry.
- Each inventory record shall represent a single physical object and be uniquely identifiable.
- The system shall allow consultation of inventory items based on their status, location, category, and characteristics.
- The system shall prevent the grouping or splitting of inventory items.

### 4.2 Lot Status and Location Management

- The system shall manage a controlled lifecycle for each inventory item.
- Each item shall always have exactly one valid status and one valid location.
- The system shall allow status and location changes only through authorized operations.
- Invalid or incoherent status transitions shall be rejected.

### 4.3 inventory operations

- The system shall support inventory operations driven by business documents, including:
  - purchase of goods
  - receipt of goods on consignment
  - return of consigned goods
  - sending goods for approval
  - return of goods from approval
  - transfer of goods for external services
  - return of goods after external services
  - sale of goods
- Each document shall result in a consistent update of the affected inventory items.

### 4.4 Certification Management

- The system shall allow association of inventory items with laboratory certificates.
- For this project, The system shall support **at most 1 single certificates for a single item** over time.
- Certification history shall be preserved to ensure traceability and auditability.

### 4.5 Traceability and History

- The system shall record all inventory operations in a traceable manner.
- For each operation, the system shall preserve:
  - the previous and new **status** of the item
  - the previous and new **location** of the item
  - the **user** responsible for the operation
  - the business context of the operation
  - the **date and time** of the operation
- The system shall allow reconstruction of the complete lifecycle of any inventory item.

### 4.6 Data Validation and Consistency

- The system shall enforce the use of controlled reference values for key attributes such as:
  - **statuses**
  - **item type**
  - **shape**
  - **colors and clarity**
  - **treatments**
  - **laboratories and service partners**
- The system shall prevent the storage of incomplete or inconsistent data.
- Operations violating business rules or lifecycle constraints shall be rejected.

### 4.7 User Roles and Responsibilities

- The system shall support multiple user roles with different responsibilities.
- The system shall restrict operations based on user roles.
- All operations affecting inventory shall be attributable to a specific user.

### 4.8 Financial Information Handling

- The system shall allow association of prices and currencies with inventory items through commercial documents.
- Financial information shall be linked to the context of the operation (purchase or sale).
- The system shall not allow direct modification of financial values outside of document-based operations.

---


# Conceptual Schema - Phase 2 

------> NEED TO ADD PNG FFILE 

PENDING

---

# [Relational Schema -  Phase 3](../diagram/er_to_relational.md)

PENDING - copy paste the content here 

---


# Interesting views / triggers / query / procedure 


## 4. Encountered Challenge 

## 5. List of Functions 

## 6. Known bugs 

## 7. Members contribution 

## 8. App interface with screen shot 

