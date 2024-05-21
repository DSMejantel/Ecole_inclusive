SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
 
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
--Sous-menu
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'Enseignant-Référent' as title,
    'referent.sql' as link,
    'writing' as icon,
    'orange' as color,
    'orange' as outline;
select 
    'type de Notification' as title,
    'modalite.sql' as link,
    'certificate-2' as icon,
    'orange' as color,
    'orange' as outline;
select 
    'Aménagement d''examen' as title,
    'examen.sql' as link,
    'school' as icon,
    'orange' as outline;
select 
    'Dispositifs' as title,
    'dispositif.sql' as link,
    'lifebuoy' as icon,
    'Orange' as color,
    'orange' as outline;
select 
    'Établissements' as title,
    'etab.sql' as link,
    'building-community' as icon,
    'orange' as outline;
select 
    'Niveaux' as title,
    'niveaux.sql' as link,
    'stairs' as icon,
    'orange' as outline;    
select 
    'Années' as title,
    'annees.sql' as link,
    'calendar-month' as icon,
    'orange' as outline; 
    
-- Nouvel établissement depuis une carte

select 
    'form' as component,
    'GET' as method,
    'Chercher sur la carte'  as validate;
select 'user_search' as name, 'Ville ou adresse' as label, $user_search as value;
 
set url = '{
    "url": "https://nominatim.openstreetmap.org/search?format=json&q=' || sqlpage.url_encode($user_search) ||'",
    "headers": {"user-agent": "ecole-inclusive/1.0"} 
}'
set api_results = sqlpage.fetch($url);
set lat = CAST($api_results->>0->>'lat' AS FLOAT)
set lon = CAST($api_results->>0->>'lon' AS FLOAT)

select 'map' as component,
  15 as zoom,
  $lat as latitude,
  $lon as longitude
  WHERE $user_search is not Null;
  
select $user_search as title,
  $lat as latitude,
  $lon as longitude
    WHERE $user_search is not Null;
  
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify
        WHERE $user_search is not Null;
select 
    'Ajouter dans le formulaire' as title,
    'etab_ajout.sql?search='||$user_search||'&lat='||$lat||'&lon='||$lon||'&tab=2' as link,
    'square-plus' as icon,
    'green' as color
        WHERE $user_search is not Null;

   

