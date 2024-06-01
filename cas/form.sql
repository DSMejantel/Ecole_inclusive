SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'4';


--- Saisir un dispositif 
SELECT 
    'form' as component,
    'cas_param.sql?cas_config=1' as action,
    'Adresse du serveur CAS' as title,
    'enregistrer' as validate;
    
    SELECT 'Serveur CAS' AS label, 'cas_url' AS name, 6 as width, TRUE as required;
        SELECT 'Disponibilité' AS label, 'open' AS name, 'checkbox' as type, 1 as value, 6 as width;
    


