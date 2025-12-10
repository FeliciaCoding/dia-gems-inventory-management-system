# Outil de gestion d’inventaire pour diamants / pierres précieuses

### Membres : Liao Pei-Wen, Maksym Makovskyi, Wu Guo Yu

##### Veuillez noter que les spécifications originales sont en anglais [specsEnglish.md](specsEnglish.md) . La version française est une traduction réalisée à l’aide d’un outil de traduction.


## Introduction :

### Produit :
Une plateforme sécurisée d’inventaire et de traçabilité pour les diamants, pierres de couleur et bijoux. Elle constitue la source de vérité unique pour l’identité, la provenance, la certification, l’évaluation, la localisation et le statut à travers les bureaux.

### Problème métier :
- Les processus basés sur le papier (notes d’achat, mémos, transferts, factures) créent des retards et des erreurs.
- Les feuilles de calcul fragmentées créent des doublons, ralentissent les recherches et génèrent des erreurs d’inventaire.
- Une traçabilité limitée (certificats, provenance) augmente les risques d’audit et de conformité.

### Objectif :
- Traçabilité de bout en bout avec transitions d’état contrôlées et auditables.
- Opérations plus rapides de la réception à la certification jusqu’à la mise en vente ; moins d’écarts ; rotation d’inventaire plus élevée.

## Profil utilisateur :

- Type d’entreprise : Négociant de pierres de couleur / diamants en B2B  
- Localisation : mondiale  
- Langue : Anglais  
  - Rôles utilisateurs :
      - Chief : Ayant un accès complet à la base de données.
      - Administrator : Suivi du statut global des marchandises, génération de liste d’inventaire, suivi des expéditions.
      - Sales : Vérification de la disponibilité / du prix / de la localisation et émission éventuelle de factures. Nécessite une recherche rapide et précise avec un statut à jour.
      - Accountant : Gère AR/AP et réconciliation. Nécessite des documents cohérents, des liens propres entre marchandises et factures + exports/imports fiables.

---

# Analyse des besoins

- L’entreprise gère des **lots** de **Diamants**, **Pierres Précieuses** et **Bijoux**. Dans ce projet une seule entreprise est modélisée, mais la solution doit évoluer à **plusieurs bureaux et partenaires** (fournisseurs, laboratoires, usines).
    
- Un **Lot** est identifié par un **LotId (Unique)** et un **Stock Name**. Il possède un **Lot Status** contrôlé (validé par la **Lot Status DB**), une **Location** (bureau/partenaire/laboratoire/usine), un **Item Type**, une **Quantity**, une **Purchase Date** et éventuellement une **Sold Date**, un **Supplier**, et des totaux (**T. Cost Price**, **T. Sale Price**).
    
- Un lot de **Diamond** enregistre **Shape**, **White Color**, **Fancy Intensity**, **Fancy Overtone**, **Fancy Color**, **Clarity**, **Origin** (si connue), **Lab** avec **Certificate No.**, et **Dimension** utilisées pour l’évaluation et la correspondance.
    
- Un lot de **Gem Stones** enregistre **Gem Type**, **Shape**, **Gem Color**, **Treatment**, **Origin** (si connue), **Lab** avec **Certificate No.**, et **Dimension**.
    
- Un lot de **Jewellry** enregistre **Jewellry Type** ; **Total center stone quantity**, **Total centered stone weight in ct**, **centered stone type** ; **Total side stone quantity**, **Total sided stone weight in ct**, **side stone type** ; plus **Gross Weight**, **Metal Type**, et **Metal Weight**.
    
- Les **Accounts/Parties** incluent **Supplier Account**, **Client Account**, et **Office Account** ; chaque partie stocke le nom légal, les contacts et les identifiants opérationnels nécessaires aux transactions B2B.
    
- Le **User Account** (Administrator, Sales, Accountant) stocke l’identifiant de connexion et le rôle, et peut être lié à un **Office/Account** pour gérer les permissions et responsabilités.
    
- Les **Documents** pilotent le cycle de vie du lot :
    
    - **Purchase note** enregistre les réceptions (transfert de propriété) avec le fournisseur, le bureau recevant, numéro/date, articles/quantité et coûts ; elle place les lots **In stock** et crée **AP**.
        
    - **Memo in** enregistre les consignations entrantes (sans achat), avec contrepartie, bureau, numéro/date, articles et évaluation optionnelle ; elle place les lots en **MI stock** avec **Ownership = supplier**.
        
    - **Return memo in** enregistre le retour des lots consignés vers la contrepartie ; elle met **Location = counterparty** et **Lot Status = Returned to supplier**, en préservant l’historique.
        
    - **Memo out** enregistre l’envoi de marchandises en approbation ; il met **Location = counterparty**, **Lot Status = Memo out**, et **Availability = false**.
        
    - **Return memo out** enregistre le retour des marchandises après approbation ; il restaure **Location = receiving office** et **Lot Status = In stock** (ou état précédent).
        
    - **Transfer** déplace des lots entre **Office / Partner / Laboratory / Factory** (tests, recoupe) ; il enregistre expéditeur/destinataire, type de service, tracking, et place **Lot Status = In Process** jusqu’à réception.
        
    - **Return transfer** confirme la réception depuis un service ; il met **Location = received-by office**, met à jour les attributs (nouveau **Certificate**, **weight**, **clarity**), et définit **In stock** (ou **Post-Recut**).
        
    - **Invoice** confirme une vente ; elle stocke client, bureau émetteur, numéro/date, articles/prix/taxes/conditions ; elle place les lots **Sold/Closed**, **Ownership = client**, **Location = client**, et crée **AR**.
        
- Chaque document et changement d’inventaire écrit un **history log** (timestamp, user, ancien→nouvel **Lot Status**, ancien→nouvel **Location**, raison) pour une traçabilité complète.
    
- Les listes de valeurs contrôlées (**Lot Status DB**, **Shape**, **Clarity**, **Fancy Intensity/Color/Overtone**, **Gem Color**, **Treatment**, **Lab**) sont maintenues comme **master data**, garantissant la validation et l’extensibilité future.

---

## Fonctionnalités :

### Workflows Documentaires

- **Purchase Note** :
	- **Purpose :** Enregistrer les marchandises reçues d’un fournisseur (transfert de propriété).

	- **Store data :** Supplier, receiving office, document/date/number, items/lots, qty, unit/total cost
	
	- **Actions** dans la DB : 
		- crée de nouvelles marchandises dans la DB  
		- définit le statut comme “In stock”  
		- définit la location au bureau recevant  
		- génère une entrée **AP**  
		- ajoute un **history log** pour la création et le changement de statut.

- **Memo In** : 
	- **Purpose :** Marchandises reçues en consignation (pas encore d’achat).

	- **Store data :** Counterparty (supplier/partner), received-by office, date, memo doc number, items, price per goods, condition notes.
	
	- **Actions** dans la DB : 
		- crée de nouvelles marchandises dans la DB  
		- met le statut à “MI stock”  
		- définit location = receiving office  
		- ajoute un history log

- **Return Memo In** :
	- **Purpose :** Retourner les marchandises au fournisseur/partenaire sans achat.
	
	- **Store data :** Counterparty, sent office, doc/date/number, items/lots, shipped-from/to, condition notes.
	
	- **Actions** dans la DB : 
		- Change locations = Counterparty  
		- met le statut = Returned to supplier  
        - ajoute un history log

- **Memo Out** : 
	- **Purpose :** Envoi des marchandises en approbation à un client/partenaire sans vente.
	
	- **Store data :** Send office, Counterparty, doc/date/number, items, date, memo price

	- **Actions** dans la DB : 
		- Change locations = Counterparty  
		- met le statut = Memo out  
		- ajoute un history log  
		- update availability = false  
		- ajoute un history log

- **Return Memo Out** : 
	- **Purpose :** Réception de nos marchandises depuis un partenaire/client sans vente.
	
	- **Store data :** Counterparty, received-by office, doc/date/number, items, date, memo price
	
	- **Actions** dans la DB : 
		- Set location = receiving office  
		- met le statut = in stock  
		- ajoute un history log

- **Transfers** entre **Office / Partner / Laboratory / Factory** 
	- **Purpose :** Envoyer des marchandises à des bureaux internes ou des partenaires externes pour services.
	
	- **Store data :** Counterparty, ship-to office, date, items, service type and tracking
	
	- **Actions** dans la DB : 
		- met location = Counterparty  
		- met le statut = "In Process"  
		- ajoute un history log

- **Return Transfers** entre **Office / Partner / Laboratory / Factory** 
	- **Purpose :** Recevoir des marchandises après services internes ou externes.
	
	- **Store data :** Counterparty, ship-to office, date, items, service type and tracking
	
	- **Actions** dans la DB : 
		- Update location = received-by office  
		- Update item info (new certificate, weight, clarity)  
		- Set status as "In Stock"  
		- Append history log

- **Invoice** : 
	- **Purpose :** Confirme une vente et transfère la propriété.
	- **Store data :** Client, issuing office, invoice number, date, items info, unit price, tax, payment terms, delivery/shipping details (if shipped).
	
	- **Actions** dans la DB : 
		- Set status as "Sold"  
		- Set location = client  
		- crée une entrée **AR**  
		- Append history log

### Workflows d’inventaire

![workFlow.png](img/workFlow.png)

### Administrator :
- Créer, voir et mettre à jour articles et lots  
- Permettre de monter / démonter des pierres dans/de bijoux  
- Permettre de suivre le statut avant et après recoupe  
- Gérer les statuts et localisations avec un cycle de vie contrôlé  
- Lier et versionner les certificats ; support de la re-certification sans perte de données  
- Générer et exporter les rapports d’expédition en excel  

### Accountant :
- Extraire Receviables / Payables basés sur purchase note et invoice  
- Produire les résumés Receviables / Payables et exporter en excel pour réconciliation  

### Sale :
- Consulter en temps réel le statut, la localisation et le prix des articles  
- Émettre des factures et marquer les articles vendus  
- Partager les informations des marchandises avec les clients  
