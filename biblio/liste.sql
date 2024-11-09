SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


-- Liste des dispositifs
SELECT 'table' as component,
  TRUE as small,
    TRUE as search,
    'Aucune ressource pour le moment...' as empty_description,
  'Éditer' as markdown;
SELECT 
  auteur AS Auteur,
  titre as Titre,
  salle as Salle,
  CASE WHEN $group_id>1 THEN '[
    ![](./icons/pencil.svg)
](biblio_edit.sql?id='||id||' "Éditer")'  END as Éditer
FROM biblio;
 

