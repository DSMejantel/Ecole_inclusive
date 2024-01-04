SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'3';

-- Enregistrer le référent créé dans la base
 INSERT INTO referent(username, nom_ens_ref, prenom_ens_ref, tel_ens_ref, email) 
    SELECT $username, $nom, $prenom, $tel_ens_ref, $email WHERE $nom IS NOT NULL
    ON CONFLICT (username) DO NOTHING;
      -- Enregistrer le référent créé dans les comptes utilisateurs
INSERT INTO user_info (username, password_hash, nom, prenom, groupe, tel, courriel)
    SELECT $username, sqlpage.hash_password(:password), $nom, $prenom, $groupe, $tel_ens_ref, $email
    WHERE $nom IS NOT NULL
    ON CONFLICT (username) DO NOTHING
    RETURNING 
     'redirect' AS component,
    'create_referent_welcome_message.sql?username=' || :username AS link;

-- If we are still here, it means that the user was not created
-- because the username was already taken.
SELECT 'redirect' AS component, 'create_referent_welcome_message.sql?error&username=' || :username AS link;

