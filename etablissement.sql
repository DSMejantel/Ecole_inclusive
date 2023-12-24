SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
        
-- Sous Menu établissement
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Établissements scolaires' as title,
    'building-community' as icon,
    'green' as color;
select 
    'Ajouter un établissement' as title,
    'etab_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id::int<2 as disabled,
    'green' as outline;
    
SELECT 'card' as component;
SELECT 
  type || ' ' || nom_etab AS title,
  'green' as color,
  description as description,
  'building-community' as icon,
  'etab_carte.sql?id=' || id as link
FROM etab;
 --Carte   
    SELECT 
    'map' as component,
    'Pôle de Mende' as title,
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


