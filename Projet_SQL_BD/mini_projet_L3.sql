
--createdb kdabira kdabira_TP_SQL

/* -------------------------------------------------------------------------
   
   TP SQL – Groupe AA5-L3 /correction 
   Date : 29/11/2025
   
   Contenu :
   -Implémentation des tables 
   - Peuplement minimal de la base de donnée 
   - Création de deux vues correspondant aux services 1 et 2
   ------------------------------------------------------------------------- 
  Remarque du professeur :
  AA Groupe AA5-L3

 --AA Vous n’avez pas mis de commentaire pour expliquer le contenu de votre fichier. Vous pouvez, par exemple, préciser le groupe, la date, le contenu, etc. Cela est utile pour vous lorsque vous consultez votre fichier ultérieurement, ainsi que pour la personne à qui vous envoyez le fichier.
 --AA Vous pourriez également utiliser un nom de fichier qui reflète le contenu du point de vue de la personne à qui vous envoyez le fichier, par exemple groupe AA.
 --AA -Vous n'avez pas indiqué les solutions MCD + shcéma relationnel choisi
 --AA Pourquoi vous avez mit les DROPS en commentaires? Vous pouvez toujours les executer sans problemes parque vous avez mit la condition : if EXISTS

  ------------------------------------------------------------------------- */

--Initialisation de la base 
--(les DROP étais en commentaire, ils nous a été conseiller de le mettre sans commentaire )
DROP VIEW IF EXISTS liste_des_categories; 
DROP VIEW IF EXISTS vehicule_loue;     

DROP TABLE IF EXISTS location;   
DROP TABLE IF EXISTS vehicule;   
DROP TABLE IF EXISTS categorie;  
DROP TABLE IF EXISTS jour;       
DROP TABLE IF EXISTS client;    




--TABLE client
--Contient tous les clients de la société de location 
CREATE TABLE client (
    reference CHAR(10) PRIMARY KEY,   --  --AA type ne correspond pas au diagrammme : le type était un "INT"
    nom       VARCHAR(50) NOT NULL, 
    prenom    VARCHAR(50) NOT NULL, 
    telephone VARCHAR(15)    -- AA pourquoi 20: il est reduit à 20 char,numéro de téléphone (format international)
);


--Question : AA Cette table est-elle utile ? Pourquoi ?
--Reponse : TABLE jour
/* Cette table permet de gérer les dates comme entité à part entière :
   - faciliter l’expression des contraintes dépendant du jour
   - un véhicule ne peut être loué qu’une fois par jour
   - un client ne peut louer qu’un seul véhicule par jour
*/
CREATE TABLE jour (
    mydate DATE PRIMARY KEY          
);


-- TABLE categorie
--Contient toutes les catégories de véhicules :
CREATE TABLE categorie (
    reference  VARCHAR(30) PRIMARY KEY, /*Remarque : nom ne correspond pas au diagrammme
    Reponse :  clé primaire artificielle présente dans le Modèle relationnel */
    intitule   VARCHAR(30),            
    tarifJour  DOUBLE PRECISION, /*Remarque : type ne correspond pas au diagrammme : 
    c'était un "INT" avant correction*/
    tarifKM    DOUBLE PRECISION/*Remarque : type ne correspond pas au diagrammme : 
    c'était un "INT" avant correction*/
             
);

--TABLE vehicule
/* Contient tous les véhicules disponibles :
   - chaque véhicule appartient à une catégorie
*/
CREATE TABLE vehicule (
    immatriculation VARCHAR(10) PRIMARY KEY,  -- --AA Pourquoi 25? : Nous l'avons reduit à 10 
    v_description     VARCHAR(200),        
    v_categorie       VARCHAR(30) REFERENCES categorie) ; /*Remarque : 
    utilisez la syntaxe simplifiée des exemples du cours, du TP et des annales; ce qui a été fait */

--TABLE location (association ternaire) : explication
/* Représente l’association entre :
   - le véhicule loué
   - le client qui loue
   - le jour de location
   Contraintes :
   - un client ne peut louer qu’un seul véhicule par jour
*/
CREATE TABLE location (
    loue        VARCHAR(10) REFERENCES vehicule, /*Remarque : 
    utilisez la syntaxe simplifiée des exemples du cours, du TP et des annales; ce qui a été fait */
    locataire   VARCHAR(10)    REFERENCES client,        
    moment      DATE        REFERENCES jour,           
    kmDepart    INT,                                       
    kmRetour    INT,                                  
    tarifChoisi VARCHAR(20)                                      
                 CHECK (tarifChoisi IN ('kilometrique','journalier')), -- vérifie la validité

    PRIMARY KEY (loue, moment, locataire),  -- Clé primaire sur la triple association

    UNIQUE (moment, locataire)    -- un client ne peut louer qu’un seul véhicule par jour
    
);
/* -------------------------------------------------------------------------
Remarque professeur : 
--Peuplement de la base 
--AA décrivez l'utilité de chaque insertion. Exemple : "une catégorie classant plusieurs véhicules", 'une catégorie ne classan aucun véhicule"
--AA chaque ligne doit servir soit à illustrer une contrainte du MCD (en particulier les cardinalités min et max des rôles), soit à tester l'application
--AA le peuplement de la base de données doit contenir un jeu de données nécessaire (i.e. minimal) et suffisant (i.e. complet) pour illustrer le MCD et pour tester l'application
-------------------------------------------------------------------------*/


--Peuplement de la base 

 --TABLE client
/* cardinalité :
   - un client peut ne pas faire une locations
   - clients peut loué plusieurs véhicules à des jour différents jours
*/

INSERT INTO client VALUES
('A1', 'Dupont', 'Jean', '0601020304'),   -- client qui loue plusieurs véhicules à différents jours
('B2', 'Martin', 'Claire', '0611223344'), -- client louant un véhicule à plusieurs jours
('C3', 'Kone', 'Abdoulaye', '0755332244'),-- client louant un seul véhicule
('E4', 'Diallo', 'Aminata', '0788991122'),-- client louant un seul véhicule
('F5', 'Durand', 'Paul', '0622334455');    -- client n’ayant jamais loué (illustration cardinalité min)


--TABLE categorie
--Remarque : AA Cardinalité? Min? Max?
/* 
   - une catégorie avec plusieurs véhicules (cardinalité max)
   - une catégorie sans véhicule (cardinalité min)
*/

INSERT INTO categorie VALUES
('CAT-A', 'Citadine',   40, 2),   -- plusieurs véhicules dans cette catégorie (AA-111-AA et EE-555-EE)
('CAT-B', 'SUV',        80, 4),   -- véhicule unique dans cette catégorie (BB-222-BB)
('CAT-C', 'Utilitaire', 100, 5),  -- véhicule unique dans cette catégorie (CC-333-CC)
('CAT-D', 'Luxe',       200, 8);  -- véhicule unique dans cette catégorie (DD-444-DD)

 --  TABLE jour
/* Plusieurs jours pour illustrer les locations sur plusieurs jours */
INSERT INTO jour (date_jour)
SELECT generate_series(
    '2025-01-10'::date,
    '2025-12-31'::date,
    interval '1 day'
);

/*
INSERT INTO jour (mydate)
SELECT generate_series(
    '2025-01-10'::date,
    '2025-12-31'::date,
    interval '1 day'
)::date;

*/



-- TABLE vehicule
/* Chaque véhicule est associé à une catégorie :
   - Certains véhicules non loués pour tester cardinalité min côté location
*/
INSERT INTO vehicule VALUES
('AA-111-AA', 'Renault Clio 5', 'CAT-A'),   -- véhicule loué plusieurs fois
('BB-222-BB', 'Peugeot 3008', 'CAT-B'),    -- véhicule loué une fois
('CC-333-CC', 'Renault Master', 'CAT-C'),  -- véhicule loué une fois
('DD-444-DD', 'Mercedes E', 'CAT-D'),      -- véhicule loué une fois
('EE-555-EE', 'Dacia Sandero', 'CAT-A'),  -- véhicule loué une fois
('FF-666-FF', 'Porsche Cayenne', 'CAT-D'); --véhicule non loué  

 --TABLE location
/* Illustrations des contraintes :
   - véhicule unique par jour
   - client unique par jour
   - un client peut louer plusieurs véhicules à différents jours
*/
INSERT INTO location VALUES
('AA-111-AA', 'A1', '2025-01-10', 12000, 12050, 'kilometrique'), -- Dupont loue AA-111-AA le 10/01
('BB-222-BB', 'B2', '2025-01-10', 54000, 54200, 'journalier'),   -- Martin loue BB-222-BB le 10/01
('EE-555-EE', 'A1', '2025-01-11', 8000, 8100, 'journalier'),     -- Dupont loue EE-555-EE le 11/01
('CC-333-CC', 'C3', '2025-01-12', 30000, 30210, 'kilometrique'), -- Kone loue CC-333-CC le 12/01
('DD-444-DD', 'F5', '2025-01-13', 15000, 15080, 'kilometrique'), -- Diallo loue DD-444-DD le 13/01
('AA-111-AA', 'C3', '2025-01-14', 12050, 12100, 'journalier');-- Dupont loue à nouveau AA-111-AA le 14/01




--LES VUES DES DEUX PREMIER SERVICE 

/*-------------------------------------------------------------------------
Remarque du professeur : 
--AA forunissez un exemple de requête utilisant la vue générée par chacun des services concerné
--AA Vous pouvez préciser un peu plus: vue service 1 : Affichage de la lise des catégories
--AA Si vous avez besoin, Vous pouvez adapter les noms des colonnes : CREATE VIEW vue_categories_tarifs (categorie, intitule, tarif-KM, tarif-Jour) AS
--AA manque examples d'utilisation des vues
-------------------------------------------------------------------------*/

--SERVICE_1 : affichage de la liste des catégorie
CREATE VIEW liste_des_categories AS
SELECT 
    intitule AS categorie,
    tarifJour AS tarif_journalier,
    tarifKM AS tarif_kilometrique
FROM categorie;

/* categorie  | tarif_journalier | tarif_kilometrique 
------------+------------------+--------------------
 Citadine   |               40 |                  2
 SUV        |               80 |                  4
 Utilitaire |              100 |                  5
 Luxe       |              200 |                  8
(4 lignes)

*/


/*-------------------------------------------------------------------------
--SERVICE_2 ; en supposant ici que la catégorie choisie et "CAT-A"
--AA Dans l' exemple de requête utilisant la vue, Vous pouvez mettre la condition WHERE cat.reference = 'CAT-A'  ;
--AA La liste devrait être ordonnée
--AA pourquoi Le Jour n'est pas le 1er Colonne?
--AA mieux encore d'afficher le taux de tarif
-------------------------------------------------------------------------*/

--SERVICE_2 : 
CREATE VIEW vehicule_loue AS
SELECT 
    l.moment AS date_location,                      
    v.v_description AS description,                 
    l.tarifChoisi AS tarifChoisi,                   
    CASE                                               
        WHEN l.tarifChoisi = 'kilometrique' THEN cat.tarifKM
        WHEN l.tarifChoisi = 'journalier'  THEN cat.tarifJour
        ELSE NULL
    END AS taux,
    c.nom,
    c.prenom,
    c.telephone
FROM vehicule v
JOIN categorie cat ON v.v_categorie = cat.reference
LEFT JOIN location l ON v.immatriculation = l.loue --AA Pourquoi LEFT : Pour pouvoir affciher correcteur les catégorie qui n'ont pas été loué
LEFT JOIN client c ON l.locataire = c.reference ; -- AA Pourquoi LEFT : pour povoir affcier les clients qui n'ont pas loué 

--On a préféré ordonné dans le script php ;

/*date_location |   description   | tarifchoisi  | taux | reference |  nom   |  prenom   | telephone  
---------------+-----------------+--------------+------+-----------+--------+-----------+------------
 2025-01-10    | Renault Clio 5  | kilometrique |    2 | CAT-A     | Dupont | Jean      | 0601020304
 2025-01-10    | Peugeot 3008    | journalier   |   80 | CAT-B     | Martin | Claire    | 0611223344
 2025-01-11    | Dacia Sandero   | journalier   |   40 | CAT-A     | Dupont | Jean      | 0601020304
 2025-01-12    | Renault Master  | kilometrique |    5 | CAT-C     | Kone   | Abdoulaye | 0755332244
 2025-01-13    | Mercedes E      | kilometrique |    8 | CAT-D     | Durand | Paul      | 0622334455
 2025-01-14    | Renault Clio 5  | journalier   |   40 | CAT-A     | Dupont | Jean      | 0601020304
               | Porsche Cayenne |              |      | CAT-D     |        |           | 
(7 lignes)*/


--Service 3

DROP VIEW IF EXISTS vehicules_disponibles;

CREATE VIEW vehicules_disponibles AS
SELECT
    v.immatriculation AS immatriculation,
    v.v_description AS description,
    v.v_categorie,          -- <== garde le nom original ici
    cat.intitule AS categorie,
    cat.tarifJour AS tarifjour,
    cat.tarifKM AS tarifkm
FROM vehicule v
JOIN categorie cat ON v.v_categorie = cat.reference;


DROP VIEW IF EXISTS vue_facture_location;



--SERVICE 5
CREATE VIEW vue_facture_location AS
SELECT
    l.locataire        AS reference_client,
    l.moment           AS date_location,
    l.kmDepart         AS km_depart,
    l.kmRetour         AS km_retour,
    l.tarifChoisi      AS mode_tarif,

    v.immatriculation  AS immatriculation,
    v.v_description    AS description,

    cat.intitule       AS categorie,
    cat.tarifJour      AS tarif_journalier,
    cat.tarifKM        AS tarif_kilometrique

FROM location l
JOIN vehicule v  ON l.loue = v.immatriculation
JOIN categorie cat ON v.v_categorie = cat.reference;





--Dans mon fichier php 
/*SELECT *
FROM vue_vehicules_disponibles vvd
WHERE vvd.v_categorie = 'CAT-A'
AND NOT EXISTS (
    SELECT 1
    FROM location l
    WHERE l.loue = vvd.immatriculation
    AND l.moment = '2025-01-10'
);


