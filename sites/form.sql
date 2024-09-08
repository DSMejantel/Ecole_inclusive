SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'2';


--- Saisir un nouveau site
SELECT 
    'form' as component,
    'Enregistrer un nouveau site' as title,
    'Créer' as validate;
    
    SELECT 'Nom du site' AS label, 'nom' AS name, 'device-desktop-analytics' as prefix_icon, TRUE as required;
    SELECT 'Adresse' AS label, 'url' AS name, 'world-www' as prefix_icon, TRUE as required;
    SELECT 'Matière' AS label, 'matière' AS name, 'chalkboard' as prefix_icon;
    SELECT 'Commentaires' AS label, 'commentaire' AS name, 'textarea' as type, 'bubble-text' as prefix_icon;


