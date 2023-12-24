SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  

SELECT 
    'alert' as component,
    'Alerte' as title,
    'Toute suppression est définitive' as description,
    'alert-triangle' as icon,
    'red' as color;       

--Sous-menu Retour
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste' as title,
    'modalite.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  

-- Supprimer le dispositif dans la base
DELETE FROM `dispositif`
WHERE id = $id;
 
 SELECT 'list' as component,
  'Liste des dispositifs' AS title,
   'Liste des dispositifs proposés sur les établissements' AS description;
SELECT 
  type AS title,
  'trash' as icon,
  'dispositif_delete.sql?id=' || id AS link
FROM dispositif;   

SELECT 
    'hero' as component,
    '/dispositif.sql' as link,
    'Retour à la liste' as link_text;
