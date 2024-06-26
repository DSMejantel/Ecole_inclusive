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
    'Toute suppression est définitive. Les types de notification déjà attribués à un élève ne peuvent pas être supprimés.' as description,
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
    'modalite.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  

    -- Supprimer la notification dans la base
DELETE FROM `modalite`
WHERE id = $id;
 
 SELECT 'list' as component,
  'Notifications' AS title,
   'Liste des notifications proposées par la MDPH' AS description;
SELECT 
  type AS title,
  CASE WHEN EXISTS (SELECT modalite_id FROM notif WHERE modalite.id = notif.modalite_id)
  THEN  'trash-off' 
  ELSE 'trash' END as icon,
  CASE WHEN EXISTS (SELECT modalite_id FROM notif WHERE modalite.id = notif.modalite_id)
  THEN ''
  ELSE 'modalite_delete.sql?id=' || id 
  END AS link
FROM modalite;   

SELECT 
    'hero' as component,
    '/modalite.sql' as link,
    'Retour à la liste' as link_text;
