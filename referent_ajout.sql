SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;
   
-- Sous Menu référent
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste des référents' as title,
    'referent.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  
    
-- Saisir un nouvel enseignant référent    
SELECT 
    'form' as component,
    'create_referent.sql' AS action,
    'Nouveau référent MDPH' as title,
    'Créer un enseignant-référent' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;

    SELECT 'username' AS name, 'id' as prefix_icon, 'Identifiant' as label, 6 as width, TRUE as required;
    SELECT 'code' AS name, 'lock' as prefix_icon, 'text' AS type, sqlpage.random_string(20) AS value, 'Code d''activation' as label, 6 as width;   
    SELECT 'Nom' AS label, 'user' as prefix_icon, 'nom' AS name, 6 as width, TRUE as required;
    SELECT 'Prénom' AS label, 'user' as prefix_icon, 'prenom' AS name, 6 as width, TRUE as required;
    SELECT 'groupe' AS name, 'Permissions' as label, 'select' as type, 4 as width,
    0        as value,
    '[{"label": "Consultant prof", "value": 1}, {"label": "Consultant AESH", "value": 2}, {"label": "Éditeur", "value": 3}, {"label": "administrateur", "value": 4}]' as options;
    SELECT 'Téléphone' AS label, 'phone' as prefix_icon, 'tel_ens_ref' AS name, CHAR(10), 4 as width;
    SELECT 'Courriel' AS label, 'mail' as prefix_icon, 'email' AS name, 4 as width;
    

SELECT 'table' as component,
    'icon' as icon,
    'nom_ens_ref' as Nom,
    'prenom_ens_ref' as Prénom,
    'tel_ens_ref' as Téléphone,
    'email' as courriel,
    1 as sort,
    1 as search;
SELECT 
  nom_ens_ref AS Nom,
  prenom_ens_ref AS Prénom,
  tel_ens_ref as Téléphone,
  email as courriel,
  'pencil' as icon
FROM referent; 

SELECT 
    'hero' as component,
    '/referent_delete.sql' as link,
    'Supprimer des référents' as link_text;

