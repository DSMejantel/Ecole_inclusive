SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../biblio.sql?restriction' AS link
        WHERE $group_id<'2';

-- Set a variable 
SET auteur_edit = (SELECT auteur FROM biblio WHERE id = $id);
SET titre_edit = (SELECT titre FROM biblio WHERE id = $id);
SET salle_edit = (SELECT salle FROM biblio WHERE id = $id);


--- Saisir une nouvelle modalité de notification  
SELECT 
    'form' as component,
    'Modifier une référence bibliographique' as title,
    'biblio.sql?update=1&id='||$id as action,
    'Modifier' as validate;
    
    SELECT 'Auteur' AS label, 'auteur_edit' AS name, 'user' as prefix_icon, $auteur_edit as value, TRUE as required;
    SELECT 'Titre' AS label, 'titre' AS name, 'book' as prefix_icon, $titre_edit as value, TRUE as required;
    SELECT 'Salle' AS label, 'salle' AS name, 'home-hand' as prefix_icon, $salle_edit as value, TRUE as required;

