SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'2';


SET edition = (SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') )
SET modif = (SELECT datetime(current_timestamp, 'localtime'))
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$eleve_edit;
UPDATE amenag SET amenagements=:amenagements2, objectifs=:objectifs2, info=:info2 WHERE id=$id
RETURNING
   'redirect' AS component,
   'notification.sql?id='||$eleve_edit||'&tab=Profil' as link;
