# Inventory Management Tool For Diamond/ Precious Stones

#####
member:  Liao Pei-Wen, Maksym Makovskyi, Wu Guo Yu




## Introduction :

### Product :
A secure inventory and traceability platform  for diamonds, colored stones and jewelry. It is the single source of truth for identity, provenance, certification, valuation, location, and status across offices.

### Business Problem:
- Paper-based processes (purchase notes, memos, transfers, invoices) create delays and errors.
- Fragmented spreadsheets create duplicates, slow searches, and inventory errors.
- Limited traceability (certificates, provenance) increases audit and compliance risk.

### Goal :
- End-to-end traceability with controlled, auditable state transitions.
- Faster operations from receiving to certification to listing; fewer variances; higher inventory turns.

## User profile  :

- Company type : Colored stones / Dimond Dealer in B2B
- Location : worldwide
- Language : English
- User roles :
    - Administrator : Tracking goods' overall status, generating inventory list, following shipment
    - Sales : Checking availability / price / location and eventually issueing invoices. Need fast, accuate search with up-to-date status and media.
    - Accountant : Handle AR/AP and reconsiliation. Need consistent documents, clean links between goods and invoice + reliable exports/ import.

---
# Analysis of needs

- The company manages **lots** of **Diamonds**, **Gem Stones**, **Jewellry**, and **Metal**. In this project a single company is modeled, but the solution must scale to **multiple offices and partners** (suppliers, laboratories, factories).
    
- A **Lot** is identified by **LotId (Unique)** and **Stock Name**. It carries a controlled **Lot Status** (validated by **Lot Status DB**), a **Location** (office/partner/lab/factory), an **Item Type**, a **Quantity**, a **Purchase Date** and optional **Sold Date**, a **Supplier**, and totals (**T. Cost Price**, **T. Sale Price**).
    
- A **Diamond** lot records **Shape**, **White Color**, **Fancy Intensity**, **Fancy Overtone**, **Fancy Color**, **Clarity**, **Origin** (if known), **Lab** with **Certificate No.**, and **Dimension** used for valuation and matching.
    
- A **Gem Stones** lot records **Gem Type**, **Shape**, **Gem Color**, **Treatment**, **Origin** (if known), **Lab** with **Certificate No.**, and **Dimension**.
    
- A **Jewellry** lot records **Jewellry Type**; **Total center stone quantity**, **Total centered stone weight in ct**, **centered stone type**; **Total side stone quantity**, **Total sided stone weight in ct**, **side stone type**; plus **Gross Weight**, **Metal Type**, and **Metal Weight**. Stones can be **mounted/unmounted** with full component traceability.
    
- A **Metal** lot (managed as an Item Type) records **Metal Type** and **Metal Weight** for valuation.
    
- **Accounts/Parties** include **Supplier Account**, **Client Account**, and **Office Account**; each party stores legal name, contact details, and operational identifiers needed for B2B transactions.
    
- **User Account** (Administrator, Sales, Accountant) stores login and role, and may link to an **Office/Account** to govern permissions and responsibility.
    
- **Documents** drive the lot lifecycle:
    
    - **Purchase note** records receipts (ownership transfers), with supplier, receiving office, number/date, items/qty, and costs; it sets lots **In stock** and creates **AP**.
        
    - **Memo in** records consignment in (no purchase), with counterparty, office, number/date, items and optional valuation; it sets **MI stock** with **Ownership = supplier**.
        
    - **Return memo in** records returning consigned lots to the counterparty; it sets **Location = counterparty** and **Lot Status = Returned to supplier**, preserving history.
        
    - **Memo out** records sending goods on approval; it sets **Location = counterparty**, **Lot Status = Memo out**, and **Availability = false**.
        
    - **Return memo out** records the return from approval; it restores **Location = receiving office** and **Lot Status = In stock** (or prior status).
        
    - **Transfer** moves lots between **Office / Partner / Laboratory / Factory** (tests, recut, (un)mount); it records ship-from/to, service type, and tracking, and sets **Lot Status = In Process** until receipt.
        
    - **Return transfer** confirms receipt from service; it sets **Location = received-by office**, updates attributes as needed (e.g., new **Certificate**, **weight**, **clarity**), and sets **In stock** (or **Post-Recut**).
        
    - **Invoice** confirms a sale; it stores client, issuing office, number/date, items/prices/taxes/terms; it sets lots **Sold/Closed**, **Ownership = client**, **Location = client**, and creates **AR**.
        
- Every document and inventory change writes a **history log** (timestamp, user, old→new **Lot Status**, old→new **Location**, reason) for complete traceability.
    
- Controlled value lists (**Lot Status DB**, **Shape**, **Clarity**, **Fancy Intensity/Color/Overtone**, **Gem Color**, **Treatment**, **Lab**) are kept as **master data**, ensuring validation and future extensibility.

---

## Functionalities:

### Document Workflows

- **Purchase Note** : 
	- **Purpose :** Record goods received from a supplier (ownership transfers to us).
	

	- **Store data :** Supplier, receiving office, document/date/number, items/lots, qty, unit/total cost
	
	- **Actions** in DB : 
		- creates new goods in DB
		- set status as “In stock”
		- set location to the receiving office
		- generates an **AP** (accounts payable) entry
		- append **history log** for creation and status change.

- **Memo In ** : 
	- **Purpose :** Goods received on consignment (no purchase yet).

	- **Store data :** Counterparty (supplier/partner), received-by office, date, memo doc number, items, price per goods, condition notes.
	
	- **Actions** in DB : 
		- creates new goods in DB
		- Create ownership as "supplier"
		- updates status as “MI stock”
		- set location = receiving office
		- append history log for creation and status change.

- **Return Memo In** :
	- **Purpose :** Send back goods to the supplier/partner without purchasing.
	
	- **Store data :** Counterparty, sent office, doc/date/number, items/lots, shipped-from/to, carrier, condition notes.
	
	- **Actions** in DB : 
		- Change locations = Counterparty
		- set status = Returned to supplier
		- append history log
		- update quality control
	
	
- **Memo Out** : 
	- **Purpose :** Sends goods on approval to a client/partner without a sale.
	
	- **Store data :** Send office, Counterparty, doc/date/number, items, date, carrier, memo price

	- **Actions** in DB : 
		- Change locations = Counterparty
		- set status = Memo out
		- append history log
		- update availability = false.
		-  append history log
	
- **Return Memo Out** : 
	- **Purpose :** Receive our goods from partner/client without a sale.
	
	- **Store data :** Counterparty, received-by office,  doc/date/number, items, date, carrier, memo price
	
	- **Actions** in DB : 
		- Set location = receiving office
		- update status = in stock 
		- update quality control
		- append history log
	
- **Transfers** between **Office / Partner / Laboratory / Factory** 
	- **Purpose :** Send goods to internal offices or to external parties for services (e.g., lab testing, recut stone, unmount/ mount center stones from/to a jewellry piece ).
	
	- **Store data :** Counterparty, ship-to office, date, items, service type, carrier and tracking
	
	- **Actions** in DB : 
		- Updates location =  Counterparty
		- Set status as " In Process"
		- Append history log

- **Return Transfers** between **Office / Partner / Laboratory / Factory** 
	- **Purpose :** Receive goods from internal offices or from external parties for services (e.g., lab testing, recut stone, unmount/ mount center stones from/to a jewellry piece ).
	
	- **Store data :** Counterparty, ship-to office, date, items, service type, carrier and tracking
	
	- **Actions** in DB : 
		- Update location = received-by offic
		- Update item info (new certificate, weight, clarity)
		- Set status as " In Stock"
		- Append history log

	
- **Invoice** : 
	- **Purpose :** Confirms a sale and transfers ownership.
	- **Store data :** Client, issuing office, invoice number, date, items info, unit price, tax, payment terms, delivery/shipping details (if shipped).
	
	- **Actions** in DB : 
		- Set status as "Sold"
		- Set Ownership = client
		- Set location = client
		- creates an **AR** (accounts receivable) entry linked to the invoice
		- Append history log


### Inventory Workflows

![workFlow.png](img/workFlow.png)

### Administrator :
- Create, view, and update items and lots
- Allow to mount / unmount stones to/from jewellry.
- Allow to track the status before and after recut.
- Manage statuses and locations using a controlled lifecycle.
- Link and version certificates, the system should support re-certification without data loss.
- Allow to store / update photos and the URL of videos
- Generate and export shipping reports in excel
### Accountant :
- Allow to extract Receviables / Payables based on purchase note and invoice
- Produce Receviables / Payables summaries and export to excel for reconcilliation
### Sale :
- Consult real-time item status, location, and pricing
- issue invoices and mark items sold.
- Share goods' info/ media with clients

