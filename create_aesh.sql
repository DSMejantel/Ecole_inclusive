SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';
        
-- Enregistrer l'aesh créé dans la base
 INSERT INTO aesh(username, aesh_name, aesh_firstname, tel_aesh, courriel_aesh, quotite, tps_ULIS, tps_mission, tps_synthese) SELECT $username, $aesh_name, $aesh_firstname, $tel_aesh, $courriel_aesh, $quotite, $tps_ULIS, $tps_mission, $tps_synthese WHERE $aesh_name IS NOT NULL
     ON CONFLICT (username) DO NOTHING;
     -- Enregistrer l'aesh créé dans les comptes utilisateurs
INSERT INTO user_info (username, activation, nom, prenom, groupe, tel, courriel)
    SELECT $username, $code, $aesh_name, $aesh_firstname, $groupe, $tel_aesh, $courriel_aesh
    WHERE $aesh_name IS NOT NULL
    ON CONFLICT (username) DO NOTHING
    RETURNING 
     'redirect' AS component,
    'create_aesh_welcome_message.sql?username=' || :username AS link;

-- If we are still here, it means that the user was not created
-- because the username was already taken.
SELECT 'redirect' AS component, 'create_aesh_welcome_message.sql?error&username=' || :username AS link;

