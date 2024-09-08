SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'3';

 UPDATE suivi SET temps=temps-0.5 WHERE id=$suivi
 RETURNING 
 'redirect' as component,
 '../etab_suivi.sql?id='||$etab||'&tab=Acc#'||$ligne as link;
