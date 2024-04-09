SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, 
CASE WHEN $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties; 
  
        
-- Sous Menu établissement
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Mon établissement' as title,
    'building-community' as icon,
    'green' as color,
    'etab_carte.sql?id=' || user_info.etab as link
     FROM etab JOIN user_info on user_info.etab=etab.id WHERE $group_id=1 GROUP BY etab.id;
select 
    'Ajouter un établissement' as title,
    'etab_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id::int<3 as disabled,
    'green' as outline;
    
-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' 
    as description_md,
    'alert-circle' as icon,
    TRUE as important,
    'orange' as color
WHERE $restriction IS NOT NULL;


--Fiches    
SELECT 'card' as component;
SELECT
    CASE WHEN  type='Lycée'   THEN'red'
    WHEN type='Collège' THEN 'orange'
    ELSE 'yellow' 
    END as color,
    CASE WHEN type='Lycée'
    THEN'building-community' 
    WHEN type='Collège' THEN 'building-community'
    ELSE 'building-cottage'      
    END as icon,
  type || ' ' || nom_etab AS title,
  description as description,
  CASE WHEN $group_id::int=1 and user_info.etab<>etab.id 
  THEN '' 
  WHEN $group_id::int=1 and user_info.etab=etab.id 
  THEN 'etab_carte.sql?id=' || id
  WHEN $group_id::int>1 
  THEN 'etab_carte.sql?id=' || id
  END as link
FROM etab LEFT JOIN user_info on user_info.etab=etab.id group by etab.id;

    
 --Carte   
    SELECT 
    'map' as component,
    12 as zoom,
    400 as height,
    AVG(Lat) as latitude,
    AVG(Lon) as longitude FROM etab WHERE type<>'---';

SELECT
  type || ' ' || nom_etab AS title,
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
  CASE WHEN $group_id::int=1 and user_info.etab<>etab.id 
  THEN '' 
  WHEN $group_id::int=1 and user_info.etab=etab.id 
  THEN 'etab_carte.sql?id=' || id
  WHEN $group_id::int>1 
  THEN 'etab_carte.sql?id=' || id
  END as link
FROM etab LEFT JOIN user_info on user_info.etab=etab.id group by etab.id; 


