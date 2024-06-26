SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'etablissement.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;
    
-- Sous Menu établissement
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Ajouter un établissement' as title,
    'etab_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id<3 as disabled,
    'green' as outline;
 --Carte   
    SELECT 
    'map' as component,
    12 as zoom,
    400 as height,
    AVG(Lat) as latitude,
    AVG(Lon) as longitude FROM etab WHERE type<>'---';

SELECT
    type || ' ' || nom_etab as title,
    Lat AS latitude, 
    Lon AS longitude,
    CASE WHEN  type='Lycée'   THEN'red'
    WHEN type='Collège' THEN 'orange'
    ELSE 'yellow' 
    END as color,
    CASE WHEN type='Lycée'
    THEN'building-community' 
    WHEN type='Collège' THEN 'building-community'
    ELSE 'building-cottage'      
    END as icon,
  'etab_carte.sql?id=' || id as link
FROM etab;        
    
 -- Fiches des établissments
 SELECT 'card' as component,
  'Établissements' AS title,
   'Liste des écoles, collèges et lycées du PIAL' AS description;
SELECT 
  type  AS description,
    CASE WHEN  type='Lycée'   THEN'red'
    WHEN type='Collège' THEN 'orange'
    ELSE 'yellow' 
    END as color,
    CASE WHEN type='Lycée'
    THEN'building-community' 
    WHEN type='Collège' THEN 'building-community'
    ELSE 'building-cottage'      
    END as icon,
  description as footer,
  nom_etab AS title,
  'etab_notif.sql?id=' || id as link
FROM etab;


