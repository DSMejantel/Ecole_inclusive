SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'3';


-- Formulaire pour ajouter un aménagement d'examen
SELECT 'form' as component, 
'examen.sql' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Effacer'           as reset;

SELECT 'Code' AS 'label', 'text' as type, 'code' AS name, 'barcode' as prefix_icon, 6 as width;
SELECT 'Mesure' AS 'label', 'textarea' as type, 'mesure' AS name, 6 as width;

