     -- Enregistrer l'aesh créé dans la base
 INSERT INTO aesh(username, aesh_name, aesh_firstname, tel_aesh, courriel_aesh, quotite, tps_ULIS, tps_mission, tps_synthese) SELECT $username, $aesh_name, $aesh_firstname, $tel_aesh, $courriel_aesh, $quotite, $tps_ULIS, $tps_mission, $tps_synthese WHERE $aesh_name IS NOT NULL
     ON CONFLICT (username) DO NOTHING;
     -- Enregistrer l'aesh créé dans les comptes utilisateurs
INSERT INTO user_info (username, password_hash, nom, prenom, groupe, tel, courriel)
    SELECT $username, sqlpage.hash_password(:password), $aesh_name, $aesh_firstname, $groupe, $tel_aesh, $courriel_aesh
    WHERE $aesh_name IS NOT NULL
    ON CONFLICT (username) DO NOTHING
    RETURNING 
     'redirect' AS component,
    'create_aesh_welcome_message.sql?username=' || :username AS link;

-- If we are still here, it means that the user was not created
-- because the username was already taken.
SELECT 'redirect' AS component, 'create_aesh_welcome_message.sql?error&username=' || :username AS link;

