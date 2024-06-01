SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'3';


--- Saisir une nouvelle modalité de notification  
SELECT 
    'form' as component,
    'Structure des classes' as title,
    'Créer' as validate;
    
    SELECT 'select' as type, 'Établissement scolaire' AS label, 'etab' AS name, json_group_array(json_object("label", nom_etab, "value", UAI)) as options FROM etab ORDER BY nom_etab ASC;
    SELECT 'Nom de la classe' AS label, 'classe' AS name, 'users-group' as prefix_icon, TRUE as required;

