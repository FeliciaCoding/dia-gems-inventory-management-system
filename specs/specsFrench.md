# Outil de gestion d’inventaire pour diamants / pierres précieuses

### Membres : Liao Pei-Wen, Maksym Makovskyi, Wu Guo Yu

##### Veuillez noter que les spécifications originales sont en anglais [specsEnglish.md](specsEnglish.md) . La version française est une traduction réalisée à l’aide d’un outil de traduction.

---


## Introduction :

### Produit :
Une plateforme sécurisée d’inventaire et de traçabilité pour les diamants, pierres de couleur et bijoux. C’est la source unique de vérité pour l’identité, la provenance, la certification, l’évaluation, la localisation et le statut des lots à travers les bureaux.

### Problématique métier :
- Les processus papier (bons d’achat, mémos, transferts, factures) créent des retards et des erreurs.
- Les tableurs fragmentés provoquent des doublons, des recherches lentes et des erreurs d’inventaire.
- La traçabilité limitée (certificats, provenance) augmente les risques d’audit et de conformité.


### Objectif :
- Traçabilité de bout en bout avec transitions d’état contrôlées et auditables.
- Opérations plus rapides de la réception à la certification puis à la mise en vente ; moins d’écarts ; rotation d’inventaire plus élevée.

---

## Profil utilisateur :

- Type d’entreprise : Négociant de pierres de couleur / diamants en B2B
- Zone : mondiale
- Langue : anglais
- Rôles utilisateurs :
    - **Administrateur** : Suivi du statut global des marchandises, génération de listes d’inventaire, suivi des expéditions.
    - **Ventes** : Vérification de la disponibilité / du prix / de la localisation et éventuellement émission de factures. Besoin d’une recherche rapide et précise avec un statut et des médias à jour.
    - **Comptable** : Gestion clients/fournisseurs (AR/AP) et rapprochements. Besoin de documents cohérents, de liens propres entre marchandises et facture + exports/imports fiables.

---

## Fonctionnalités :

### Flux documentaires

- **Bon d’achat (Purchase Note)**
- **Mémo entrée / Retour mémo entrée**
- **Mémo sortie / Retour mémo sortie**
- **Transferts** entre **Bureau / Partenaire / Laboratoire / Usine**, avec détails d’expédition.
- **Facturation** des ventes.

### Flux d’inventaire

![workFlow.png](img/workFlow.png)

### Administrateur :
- Créer, afficher et mettre à jour articles et lots
- Permettre de **sertir / désertir** des pierres sur/des bijoux.
- Suivre le statut **avant et après re-taillage**.
- Gérer les statuts et localisations via un cycle de vie contrôlé.
- Lier et versionner les certificats ; le système doit supporter la **re-certification** sans perte de données.
- Stocker / mettre à jour les photos et l’URL des vidéos.
- Générer et exporter des rapports d’expédition en Excel.

### Comptable :
- Extraire **comptes clients / comptes fournisseurs (AR/AP)** à partir des bons d’achat et des factures.
- Produire des synthèses AR/AP et exporter en Excel pour le rapprochement.

### Ventes :
- Consulter en temps réel le statut, la localisation et le prix des articles.
- Émettre des factures et marquer les articles comme vendus.
- Partager avec les clients les informations/médias des marchandises.

---

## Données requises :
Les données suivantes seront requises (liste non exhaustive) :

#### Données générales de la marchandise
- **ID de lot** (unique)
- **Nom de stock**
- **Statut du lot**
- **Base de statuts du lot (Lot Status DB)**
- **Localisation**
- **Type d’article**
    - Diamants
    - Pierres gemmes
    - Bijoux
    - Métal
- **Quantité**
- **Date d’achat**
- **Date de vente**
- **Fournisseur**
- **Prix de revient total**
- **Prix de vente total**

#### Diamants
- **Forme :**
    - Rond (Round Cut)
    - Poire (Pear Shape)
    - Coussin (Cushion Shape)
    - Radiant (Radiant Cut)
    - Cœur (Heart Shape)
    - Émeraude (Emerald Cut)
    - Baguette
    - Briolette
    - Cerf-volant (Kite)
    - Marquise
    - Ovale
    - Princess
    - Trillion
- **Couleur (blanc) :**
- **Intensité Fancy :**
    - Fancy Dark
    - Fancy Deep
    - Fancy Intense
    - Fancy Vivid
    - Fancy Light
    - Light
    - Very Light
    - Faint
- **Nuance Fancy (Overtone) :**
- **Couleur Fancy :**
- **Pureté :**
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
- **Origine :**
    - Afrique
    - Angola
    - Argyle
    - Brésil
    - Canada
    - Inde
    - Afrique du Sud
- **Laboratoire :**
    - GIA
    - Argyle
    - HRD
- **N° de certificat**
- **Dimensions**

#### Pierres gemmes
- **Type de gemme :**
    - Rubis
    - Émeraude
    - Saphir
- **Forme :**
    - Rond (Round Cut)
    - Poire (Pear Shape)
    - Coussin (Cushion Shape)
    - Radiant (Radiant Cut)
    - Émeraude (Emerald Cut)
    - Ovale
- **Couleur de la gemme :**
    - Pigeon Blood
    - Royal Blue
- **Traitement :**
    - Sans huile
    - Huile légère (Minor Oil)
    - Huile
    - Chauffé (Heated)
    - Non chauffé (No Heat)
- **Origine :**
    - Birmanie
    - Mozambique
    - Cachemire
    - Sri Lanka
    - Colombie
    - Siam
    - Ceylan
- **Laboratoire :**
    - SSEF
    - MUZO
    - Gübelin
- **N° de certificat**
- **Dimensions**

#### Bijoux
- **Type de bijou**
- **Quantité totale de pierres centrales**
- **Poids total des pierres centrales (ct)**
- **Type de pierre centrale**

- **Quantité totale de pierres latérales**
- **Poids total des pierres latérales (ct)**
- **Type de pierres latérales**

- **Poids brut**
- **Type de métal**
- **Poids du métal**

#### Comptes
- Compte utilisateur
- Compte fournisseur
- Compte client
- Compte bureau

#### Documents
- Bon d’achat
- Mémo entrée / Retour mémo entrée
- Mémo sortie / Retour mémo sortie
- Transfert :
    - Bureau
    - Partenaire
    - Laboratoire
    - Usines
- Facture
