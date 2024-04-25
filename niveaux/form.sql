SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


--- Saisir une nouvelle modalité de notification  
SELECT 
    'form' as component,
    'Niveaux de scolarité' as title,
    'Créer' as validate;
    
    SELECT 'Niveau' AS label, 'niv' AS name, 'stairs' as prefix_icon, TRUE as required;

