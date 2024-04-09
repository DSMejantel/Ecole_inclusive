SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  

DELETE FROM referent
WHERE referent.id = $id
RETURNING
   'text' AS component,
   'L''enseignant-référent ' || nom_ens_ref ||  ' ' || prenom_ens_ref ||' a été supprimé.

[Retour à la liste des référents](referent.sql)' as contents_md;
