SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Cas où un utilisateur a pu être crée sans passer par la procédure de code d'activation
-- Enregistrer la date de la connexion
SET connect = (SELECT datetime(current_timestamp, 'localtime'))
UPDATE user_info
SET connexion=$connect
WHERE username = $user_edit;

-- Mise à jour du mot de passe
UPDATE user_info SET  password_hash=sqlpage.hash_password(:password) WHERE username=$user_edit and :password is not null
RETURNING
   'redirect' AS component,
   'index.sql' as link;

