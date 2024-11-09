SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

-- Supprime l'affectation à une classe
DELETE FROM equipe_synthese WHERE username=$id;
-- Insère l'affectation à un dispositif
INSERT INTO equipe_synthese(username, classe_id)
SELECT
$id as username,
CAST(value AS integer) as classe_id from json_each(:equipe) WHERE :equipe IS NOT NULL

RETURNING
   'redirect' AS component,
   'comptes.sql#'||$id as link;


  

