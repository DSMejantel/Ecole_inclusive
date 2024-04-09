SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

SELECT 'form' AS component,
    'Nouveau compte utilisateur' AS title,
'create_user.sql' AS action,
    'Créer' AS validate,
    'green'           as validate_color,
    'Recommencer'           as reset;

-- Formulaire
SELECT 'username' AS name, 'Identifiant' as label, 6 as width;
SELECT 'code' AS name, 'text' AS type, sqlpage.random_string(20) AS value, 'Code d''activation' as label, 6 as width;
SELECT 'nom' AS name, 'Nom' as label, 4 as width;
SELECT 'prenom' AS name, 'Prénom' as label, 4 as width;
    SELECT 'Etablissement' AS name, 'select' as type, 4 as width, json_group_array(json_object("label", nom_etab, "value", id)) as options FROM (select * FROM etab ORDER BY nom_etab ASC);
    SELECT 'Téléphone' AS label, 'tel' AS name, 4 as width;
    SELECT 'Courriel' AS label, 'courriel' AS name, 4 as width;
SELECT 'groupe' AS name, 'Permissions' as label, 'select' as type, 4 as width,
    0        as value,
    '[{"label": "Consultant prof", "value": 1}, {"label": "Consultant AESH", "value": 2}, {"label": "Éditeur", "value": 3}, {"label": "administrateur", "value": 4}]' as options;

