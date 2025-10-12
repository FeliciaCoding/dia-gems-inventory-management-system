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

## Functionalities:

### Document Workflows

- **Purchase Note**
- **Memo In / Return Memo In**
- **Memo Out / Return Memo Out**
- **Transfers** between **Office / Partner / Laboratory / Factory** with shipping details.
- **Invoice** issuance for sales.

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



## Required Data:
Following data will be required but not limited to :
#### General Good Data
-  LotId (Unique)
-  Stock Name
-  Lot Status
-  Lot Status DB
-  Location
-  Item Type
    - Diamonds
    - Gem Stones
    - Jewellry
    - Metal
- Quantity
- Purchase Date:
- Sold Date :
- Supplier
- T. Cost Price
- T. Sale Price
#### Diamonds
- Shape:
    - Round Cut
    - Pear Shape
    - Cushion Shape
    - Radiant Cut
    - Heart Shape
    - Emerald Cut
    - Baquette
    - Briolette
    - Kite
    - Marquise
    - Oval
    - Princess
    - Trillion
- White Color :
- Fansy Intensity:
    - Fansy Dark
    - Fansy Deep
    - Fansy Intense
    - Fansy Vivid
    - Fansy Light
    - Light
    - Very Light
    - Faint
- Fansy Overtone :
- Fansy Color:
- Clarity 
    - FL
    - IF
    - VVS1
    - VVS2
    - VS1
    - VS2
    - SI1
    - SI2
    - I1
    - I2
-  Origin :
    - Africa
    - Angola
    - Argyle
    - Brazil
    - Canada
    - India
    - South Africa
-  Lab :
    - GIA
    - Argyle
    - HDR
- Certificate No. 
- Dimension

#### Gem Stones
- Gem Type:
    - Ruby
    - Emerald
    - Sapphire
- Shape:
    - Round Cut
    - Pear Shape
    - Cushion Shape
    - Radiant Cut
    - Emerald Cut
    - Oval
- Gem Color :
    - Pigeon Blood
    - Royal Blue
- Treatment :
    - No oil
    - Minor Oil
    - Oil
    - Heated
    - No Heat
-  Origin :
    - Burma
    - Mozambique
    - Kashmir
    - Sri Lanka
    - Columbia
    - Siam
    - Ceylon
-  Lab :
    - SSEF
    - MUZO
    - Güblin
- Certificate No. 
- Dimension:

#### Jewellry

- Jewellry Type
- Total center stone quantity
- Total centered stone weight in ct
- centered stone type

- Total side stone quantity
- Total sided stone weight in ct.
- side stone type

- Gross Weight
- Metal Type
- Metal Weight

#### Account
- User Account
- Supplier Account
- Client Account
- Office Account

#### Documents
- Purchase note
- Memo in / return memo in
- Memo out / return memo out
- Transfer :
    - Office
    - partner
    - Lab
    - factories
- Invoice 



 

