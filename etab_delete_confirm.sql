SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

SET etab_uai= (SELECT UAI FROM etab WHERE etab.id = $id);

DELETE FROM etab
WHERE etab.id = $id
RETURNING
   'redirect' AS component,
   'etab_ajout.sql?suppression=1&UAI='||$etab_uai as link
   FROM etab WHERE etab.id = $id;


