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
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;
    
    -- Enregistrer la notification dans la base
 INSERT INTO etab(type, nom_etab, description, Lat, Lon) SELECT $type, $nom_etab, $description, $Lat, $Lon WHERE $description IS NOT NULL;

-- Onglets
SET tab=coalesce($tab,1);
select 'tab' as component;
select  'Ajouter depuis une carte'  as title, 'world' as icon, 1  as active, CASE WHEN $tab=1 THEN 'orange' ELSE 'green' END as color, 'etab_ajout.sql?tab=1' as link;
select  'Ajouter depuis un formulaire' as title, 'forms' as icon, 1 as active, CASE WHEN $tab=2 THEN 'orange' ELSE 'green' END as color, 'etab_ajout.sql?tab=2' as link; 

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
    
    SELECT 'Catégorie' AS label, 'type' AS name, 6 as width, 'select' as type, 1 as value, TRUE as searchable, '[{"label": "---", "value": "---"}, {"label": "École", "value": "école"}, {"label": "Collège", "value": "Collège"}, {"label": "Lycée", "value": "Lycée"}]' as options WHERE $tab=2;
    SELECT 'Établissement scolaire' AS label, 'nom_etab' AS name, 6 as width, $search as value, TRUE as required WHERE $tab=2;
    SELECT 'Adresse' AS label, 'description' AS name WHERE $tab=2;
    SELECT 'Latitude' AS label, 'Lat' AS name, 6 as width, $lat as value WHERE $tab=2;
    SELECT 'Longitude' AS label, 'Lon' AS name, 6 as width, $lon as value WHERE $tab=2;

select 
    'button' as component
    WHERE $tab=2;   
select 
    'etab_ajout'         as form,
    'green'      as color,
    'square-plus' as icon,
    'Ajouter'         as title
    WHERE $tab=2;
 
    


   

