SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'2';


--- Saisir un nouveau livre audio
SELECT 
    'form' as component,
    'Enregistrer  un livre audio' as title,
    'Créer' as validate;
    
    SELECT 'Auteur' AS label, 'auteur' AS name, 'user' as prefix_icon, TRUE as required;
    SELECT 'Titre' AS label, 'titre' AS name, 'book' as prefix_icon, TRUE as required;
    SELECT 'Salle' AS label, 'salle' AS name, 'home-hand' as prefix_icon, TRUE as required;


