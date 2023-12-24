SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste des AESH' as title,
    'aesh.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;    

--Formulaire d'ajout    
 SELECT 
    'form' as component,
    'Ajouter un AESH' as title,
    'Renseigner un AESH' as contents,
    'create_aesh.sql' AS action,
    'Valider' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;
    
    SELECT 'username' AS name, 'Identifiant' as label, 6 as width;
    SELECT 'password' AS name, 'password' AS type, '^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$' AS pattern, 'Le mot de passe doit comporter au moins 8 caractères : au moins une lettre majuscule et une lettre minuscule, au moins un chiffre et au moins un caractère spécial.' AS description, 'Mot de passe' as label, 6 as width;
    SELECT 'Nom' AS label, 'aesh_name' AS name, 6 as width;
    SELECT 'Prénom' AS label, 'aesh_firstname' AS name, 6 as width;
    SELECT 'groupe' AS name, 'Permissions' as label, 'select' as type, 4 as width,
    0        as value,
    '[{"label": "Consultant", "value": 1}, {"label": "Éditeur", "value": 2}, {"label": "administrateur", "value": 3}]' as options;
    SELECT 'Téléphone' AS label, 'tel_aesh' AS name, 4 as width;
    SELECT 'Courriel' AS label, 'courriel_aesh' AS name, 4 as width;
    SELECT 'Quotité' AS label, 'quotite' AS name, 'number' AS type, 3 as width;
            SELECT 'Temps en ULIS' AS label, 'tps_ULIS' AS name, 'number' AS type, 0.5 as step, 3 as width;
            SELECT 'Temps d''activités' AS label, 'tps_mission' AS name, 'number' AS type, 0.5 as step, 3 as width;
            SELECT 'Temps de Synthèse' AS label, 'tps_synthese' AS name, 'number' AS type, 0.5 as step, 3 as width;

