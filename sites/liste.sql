SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


-- Liste des dispositifs
SELECT 'list' as component,
  'Aucune ressource saisie'      as empty_title,
  TRUE as compact,
  TRUE as wrap;
SELECT 
  nom AS title,
  coalesce(matière,'-')||' '||coalesce(commentaire,'-') as description,
  'world-www' as icon,
  url as link,
  'site_edit.sql?id='||id as edit_link
FROM site;
 

