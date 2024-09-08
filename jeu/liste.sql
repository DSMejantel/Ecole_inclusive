SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


-- Liste des dispositifs
SELECT 'table' as component,
  TRUE as small,
  'Éditer' as markdown;
SELECT 
  nom AS Jeux,
  matière as Matière,
  commentaire as Commentaire,
  salle as Salle,
  CASE WHEN $group_id>1 THEN '[
    ![](./icons/pencil.svg)
](jeux_edit.sql?id='||id||' "Éditer")'  END as Éditer
FROM jeu;
 

