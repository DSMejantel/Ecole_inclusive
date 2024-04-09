SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

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
    
 SELECT 
    'form' as component,
    'Formulaire d''ajout d''AESH' as title,
    'Renseigner un AESH' as contents,
    'create_aesh.sql' AS action,
    'Valider' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;
    
    SELECT 'username' AS name, 'Identifiant' as label, 'id' as prefix_icon, 6 as width;
    SELECT 'code' AS name, 'lock' as prefix_icon, 'text' AS type, sqlpage.random_string(20) AS value, 'Code d''activation' as label, 6 as width;
    SELECT 'Nom' AS label, 'aesh_name' AS name, 'user' as prefix_icon, 6 as width;
    SELECT 'Prénom' AS label, 'aesh_firstname' AS name, 'user' as prefix_icon, 6 as width;
    SELECT 'groupe' AS name, 'Permissions' as label, 'select' as type, 4 as width,
    0        as value,
    '[{"label": "Consultant prof", "value": 1}, {"label": "Consultant AESH", "value": 2}, {"label": "Éditeur", "value": 3}, {"label": "administrateur", "value": 4}]' as options;
    SELECT 'Téléphone' AS label, 'phone' as prefix_icon,'tel_aesh' AS name, 4 as width;
    SELECT 'Courriel' AS label, 'mail' as prefix_icon,'courriel_aesh' AS name, 4 as width;
    SELECT 'Quotité' AS label, 'quotite' AS name, 'calendar-time' as prefix_icon, 'number' AS type, 3 as width;
            SELECT 'Temps en ULIS' AS label, 'clock' as prefix_icon, 'tps_ULIS' AS name, 'number' AS type, 0.5 as step, 3 as width;
            SELECT 'Temps d''activités' AS label, 'clock-play' as prefix_icon,'tps_mission' AS name, 'number' AS type, 0.5 as step, 3 as width;
            SELECT 'Temps de Synthèse' AS label, 'clock-question' as prefix_icon,'tps_synthese' AS name, 'number' AS type, 0.5 as step, 3 as width;

