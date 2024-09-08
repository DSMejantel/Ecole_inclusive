SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../site.sql?restriction' AS link
        WHERE $group_id<'2';

-- Set a variable 
SET nom_edit = (SELECT nom FROM site WHERE id = $id);
SET url_edit = (SELECT url FROM site WHERE id = $id);
SET matière_edit = (SELECT matière FROM site WHERE id = $id);
SET commentaire_edit = (SELECT commentaire FROM site WHERE id = $id);


--- Saisir une nouvelle modalité de notification  
SELECT 
    'form' as component,
    'Enregistrer un nouveau matériel de jeu' as title,
    'site.sql?update=1&id='||$id as action,
    'Modifier' as validate;

    SELECT 'Nom du site' AS label, 'nom_edit' AS name, 'device-desktop-analytics' as prefix_icon, $nom_edit as value, TRUE as required;    
    SELECT 'Adresse' AS label, 'url' AS name, 'world-www' as prefix_icon, $url_edit as value, TRUE as required;
    SELECT 'Matière' AS label, 'matière' AS name, 'chalkboard' as prefix_icon, $matière_edit as value;
    SELECT 'Commentaires' AS label, 'commentaire' AS name, 'textarea' as type, $commentaire_edit as value;


