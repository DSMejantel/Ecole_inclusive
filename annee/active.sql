SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'4';

UPDATE annee SET active=0;

 UPDATE annee SET active=1 WHERE annee=$annee
 RETURNING 
 'redirect' as component,
 '../annees.sql' as link;
