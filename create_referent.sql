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

