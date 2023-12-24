SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id::int<>'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
--
-- Set a variable 
SET nom_edit = (SELECT nom FROM user_info WHERE username = $id);
SET prenom_edit = (SELECT prenom FROM user_info WHERE username = $id);
SET group_edit = (SELECT groupe FROM user_info WHERE username = $id);
SET tel_edit = (SELECT tel FROM user_info WHERE username = $id);
SET courriel_edit = (SELECT courriel FROM user_info WHERE username = $id);
/*SELECT 'text' AS component,
$nom_edit as contents;*/

--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste des comptes' as title,
    'comptes.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  
select 
    'Changer le mot de passe' as title,
    'comptes_edit_password.sql?id='||$id as link,
    'lock' as icon,
    'red' as outline;  

-- Compte concerné par la modification
SELECT 
    'alert' as component,
    'Alerte' as title,
    'Visualiser les changements opérés' as description,
    'alert-triangle' as icon,
    'green' as color;
    
SELECT 'table' as component,
    'nom' as Nom,
    'prenom' as Prénom,
    'tel' as Téléphone,
    'courriel' as courriel;
SELECT 
  username as Identifiant,
  nom AS Nom,
  prenom AS Prénom,
  tel as Téléphone,
  courriel as courriel
FROM user_info WHERE username=$id; 
    
--- Formulaire de Mise à jour
SELECT 
    'form' as component,
    'comptes_edit_confirm.sql?id='||$id as action,
    'Mettre à jour' as validate,
    'orange'           as validate_color;
    SELECT 'Nom' AS label, 'nom' AS name, $nom_edit as value, 6 as width;
    SELECT 'Prénom' AS label, 'prenom' AS name, $prenom_edit as value, 6 as width;
    SELECT 'Téléphone' AS label, 'tel' AS name, $tel_edit as value, 4 as width;
    SELECT 'Courriel' AS label, 'courriel' AS name, $courriel_edit as value, 4 as width;
    SELECT 'Droits :' AS label, 'groupe' AS name, 'select' as type, '[{"label": "Consultant", "value": 1}, {"label": "Éditeur", "value": 2}, {"label": "administrateur", "value": 3}]' as options, $group_edit::integer as value, 4 as width;



 
   
 

