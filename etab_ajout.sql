SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
SET page='Établissements';  
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;
    
    -- Enregistrer l''établissement dans la base
 INSERT INTO etab(type, nom_etab, UAI, description, Lat, Lon) SELECT :type, :nom_etab, :UAI, :description, :Lat, :Lon WHERE :description IS NOT NULL;

-- Onglets
SET tab=coalesce($tab,0);
select 'tab' as component;
select  'Liste'  as title, 'list-check' as icon, 1  as active, CASE WHEN $tab=0 THEN 'orange' ELSE 'green' END as color, 'etab_ajout.sql?tab=0' as link;
select  'Ajouter depuis une carte'  as title, 'world' as icon, 1  as active, CASE WHEN $tab=1 THEN 'orange' ELSE 'green' END as color, 'etab_ajout.sql?tab=1' as link;
select  'Ajouter depuis un formulaire' as title, 'forms' as icon, 1 as active, CASE WHEN $tab=2 THEN 'orange' ELSE 'green' END as color, 'etab_ajout.sql?tab=2' as link; 
select  'Importer une liste' as title, 'upload' as icon, 1 as active, CASE WHEN $tab=3 THEN 'orange' ELSE 'green' END as color, 'etab_ajout.sql?tab=3' as link; 

--Message
SELECT 'alert' as component,
    'Confirmation' as title,
    'établissement '||:UAI||' supprimé.' as description_md,
    'alert-circle' as icon,
    TRUE as dismissible,
    'orange' as color
    WHERE $suppression=1;

-- Liste
SELECT 'table' as component,
    'actions' AS markdown,
    1 as sort,
    1 as search
        WHERE $tab=0;
    
SELECT 
  etab.nom_etab as Établissement,
  etab.UAI as UAI,
  CASE
WHEN $group_id>3 THEN
'[
  ![](./icons/pencil.svg)
](etab_edit.sql?id='||etab.id||' "Éditer")[
  ![](./icons/trash.svg)
](etab_delete.sql?id='||etab.id||' "Supprimer")'
 
ELSE 
'[
    ![](./icons/trash-off.svg)
]()' 
END as actions
FROM etab Where $tab=0;

-- Nouvel établissement   
select 
    'divider' as component,
    'Ajouter depuis une carte'   as contents
    WHERE $tab=1;
      
select 
    'form' as component,
    'etab_ajout_carte.sql' as action,
    'etab_ajout_carte' as id,
    ''  as validate
    WHERE $tab=1;
select 'user_search' as name, 'Ville ou adresse' as label
    WHERE $tab=1; 
   
select 
    'button' as component,
    'center' as justify
        WHERE $tab=1;    
select 
    'etab_ajout_carte' as form,
    'etab_ajout_carte.sql' as link,
    'orange'    as outline,
    'world' as icon,
    'Rechercher'  as title
    WHERE $tab=1; 

select 
    'divider' as component,
    'Ajouter depuis un formulaire'   as contents
    WHERE $tab=2; 
SELECT 
    'form' as component,
    'Nouvel établissement' as title,
    'etab_ajout' as id,
    ''     as validate,
    'Recommencer' as reset
    WHERE $tab=2;
    
    SELECT 'Catégorie' AS label, 'type' AS name, 3 as width, 'select' as type, 1 as value, TRUE as searchable, '[{"label": "---", "value": "---"}, {"label": "École", "value": "École"}, {"label": "Collège", "value": "Collège"}, {"label": "Lycée", "value": "Lycée"}]' as options WHERE $tab=2;
    SELECT 'Établissement scolaire' AS label, 'nom_etab' AS name, 'building-community' as prefix_icon, 6 as width, $search as value, TRUE as required WHERE $tab=2;
    SELECT 'UAI' AS label, 'UAI' AS name, 'barcode' as prefix_icon, 3 as width WHERE $tab=2;
    SELECT 'Adresse' AS label, 'description' AS name, 'mail' as prefix_icon, 6 as width WHERE $tab=2;
    SELECT 'Latitude' AS label, 'Lat' AS name, 'world-latitude' as prefix_icon, 3 as width, $lat as value WHERE $tab=2;
    SELECT 'Longitude' AS label, 'Lon' AS name, 'world-longitude' as prefix_icon, 3 as width, $lon as value WHERE $tab=2;

select 
    'button' as component
    WHERE $tab=2;   
select 
    'etab_ajout'         as form,
    '?tab=0' as link,
    'green'      as color,
    'square-plus' as icon,
    'Ajouter'         as title
    WHERE $tab=2;
    
--- Importation
select 
    'form'       as component,
    'Importer des établissement' as title,
    'Envoyer'  as validate,
    './etab_csv_upload.sql' as action
    WHERE $tab=3;
select 
    'comptes_data_input' as name,
    'file'               as type,
    'text/csv'           as accept,
    'Fichier .csv pour importer des établissements'           as label,
    'Envoyer un fichier CSV avec ces colonnes séparées par des points virgules et encodé en UTF-8 : type, UAI, nom_etab, Lon, Lat, description' as description,
    TRUE  as required
        WHERE $tab=3;

-- Télécharger les données
select 
    'divider' as component,
    'Outils d''importations'   as contents
        WHERE $tab=3;
SELECT 
    'csv' as component,
    'Exporter le fichier des établissements ' as title,
    'etablissement' as filename,
    'file-download' as icon,
    'green' as color
        WHERE $tab=3;
SELECT 
    type as type,
    UAI as UAI,
    nom_etab as nom_etab,
    Lon as Lon,
    Lat as Lat,
    description as description
  FROM etab 
      WHERE $tab=3 ORDER BY etab.nom_etab ASC; 
 
    


   

