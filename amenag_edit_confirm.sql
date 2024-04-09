SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

-- Ouverture exceptionnelle de droits pour le professeur principal de la classe          
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username join eleve WHERE login_session.id = sqlpage.cookie('session') and user_info.classe<>eleve.classe and eleve.id=$eleve),3);
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';


SET edition = (SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') )
SET modif = (SELECT datetime(current_timestamp, 'localtime'))
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$eleve_edit;
UPDATE amenag SET amenagements=:amenagements2, objectifs=:objectifs2, info=:info2 WHERE id=$id
RETURNING
   'redirect' AS component,
   'notification.sql?id='||$eleve_edit||'&tab=Profil' as link;
