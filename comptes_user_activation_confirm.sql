SELECT 'redirect' AS component,
        'signin.sql?activation' AS link
WHERE :code<>(SELECT activation FROM user_info WHERE username=$user_edit);

-- Supprime le code d'activation
UPDATE user_info set activation = NULL WHERE username=$user_edit; 

-- Enregistrer la date de la connexion
SET connect = (SELECT datetime(current_timestamp, 'localtime'))
UPDATE user_info
SET connexion=$connect
WHERE username = $user_edit;

-- Mise à jour du mot de passe
UPDATE user_info SET  password_hash=sqlpage.hash_password(:password) WHERE username=$user_edit and :password is not null
 RETURNING
   'redirect' AS component,
   'signin.sql' as link;

