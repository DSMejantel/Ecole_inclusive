SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id::int<>'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

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
    'comptes_edit_activation_confirm.sql?id='||$id as action,
    'Mettre à jour' as validate,
    'orange'           as validate_color;
SELECT 'code' AS name, 'text' AS type, sqlpage.random_string(20) AS value, 'Nouveau code d''activation' as label, 6 as width;


