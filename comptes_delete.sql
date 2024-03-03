SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;


SELECT 
    'alert' as component,
    'Alerte' as title,
        'red' as color,
  'Ce compte va être supprimé. Toute suppression est définitive !' 
 as description;
      
-- Isolement du compte dans une liste
SELECT 'table' as component,
    'Actions' as markdown;
   
SELECT 
nom AS Nom,
  prenom AS Prénom,
  groupe as Permissions,
      '[
    ![](./icons/trash.svg)
](comptes_delete_confirm.sql?id='||$id||') ' as Actions
FROM user_info Where username=$id;

SELECT 
    'hero' as component,
    '/comptes.sql' as link,
    'Retour à la liste' as link_text;
