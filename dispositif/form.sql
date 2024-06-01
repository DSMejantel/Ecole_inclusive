SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'3';


--- Saisir un dispositif 
SELECT 
    'form' as component,
    'dispositif_ajout.sql' as action,
    'Créer un nouveau dispostif' as title,
    'enregistrer' as validate;
    
    SELECT 'Dispositif' AS label, 'dispo' AS name, 'lifebuoy' as prefix_icon, TRUE as required;
        SELECT 'Droits réservés aux coordonnateurs' AS label, 'coordo' AS name, 'checkbox' as type, 1 as value, 6 as width;
    


