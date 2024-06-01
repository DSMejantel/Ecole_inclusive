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
    'annees.sql' as action,
    'Créer un nouvelle année scolaire' as title,
    'enregistrer' as validate;
    
    SELECT 'Année scolaire' AS label, 'an' AS name, 'calendar-month' as prefix_icon, TRUE as required;
       
    


