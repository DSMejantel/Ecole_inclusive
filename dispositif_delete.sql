SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  

SELECT 
    'alert' as component,
    'Alerte' as title,
    'Toute suppression est définitive. Les dispositifs déjà attribués à un élève ne peuvent pas être supprimés.' as description,
    'alert-triangle' as icon,
    TRUE as important,
    'red' as color;       

--Sous-menu Retour
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste' as title,
    'dispositif.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  

-- Supprimer le dispositif dans la base
DELETE FROM `dispositif`
WHERE id = $id;
 
 SELECT 'list' as component,
  'Liste des dispositifs' AS title,
   'Liste des dispositifs proposés sur les établissements' AS description;
SELECT 
  dispo AS title,
    CASE WHEN EXISTS (SELECT dispositif_id FROM affectation WHERE dispositif.id = affectation.dispositif_id)
  THEN  'trash-off' 
  ELSE 'trash' END as icon,
  CASE WHEN EXISTS (SELECT dispositif_id FROM affectation WHERE dispositif.id = affectation.dispositif_id)
  THEN ''
  ELSE 'dispositif_delete.sql?id=' || id 
  END AS link
FROM dispositif order by dispo ASC;   

SELECT 
    'hero' as component,
    '/dispositif.sql' as link,
    'Retour à la liste' as link_text;
