SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<'4';

UPDATE user_info
SET activation=Null
returning 
'redirect' AS component,
'parametres.sql?tab=Comptes' as link;

-- If the insert failed, warn the user
select 'alert' as component,
    'red' as color,
    'alert-triangle' as icon,
    'Problème détecté' as title,
    'La suppression des codes n''a pu être effectuée.' as description;

