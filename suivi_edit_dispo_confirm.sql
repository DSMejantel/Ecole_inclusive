SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

-- Mets à jour les infos de dernières modifications de l'élève	
SET edition = (SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') )
SET modif = (SELECT datetime(current_timestamp, 'localtime'))
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id;

-- Supprime l'affectation à un dispositif
DELETE FROM affectation WHERE eleve_id=$eleve_edit;
-- Insère l'affectation à un dispositif
INSERT INTO affectation(eleve_id, dispositif_id)
SELECT
$eleve_edit as eleve_id,
CAST(value AS integer) as dispositif_id from json_each(:dispositif) WHERE :dispositif IS NOT NULL

RETURNING
   'redirect' AS component,
   'notification.sql?id='||$eleve_edit||'&tab=Profil' as link;


  

