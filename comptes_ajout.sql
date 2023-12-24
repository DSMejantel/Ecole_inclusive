SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

SELECT 'form' AS component,
    'Nouveau compte utilisateur' AS title,
'create_user.sql' AS action,
    'Créer' AS validate,
    'green'           as validate_color,
    'Recommencer'           as reset;


SELECT 'username' AS name, 'Identifiant' as label, 6 as width;
SELECT 'password' AS name, 'password' AS type, '^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[-+!*$@%_])([-+!*$@%_\w]{8,15})$' AS pattern, 'Le mot de passe doit comporter au moins 8 caractères : au moins une lettre majuscule et une lettre minuscule, au moins un chiffre et au moins un caractère spécial.' AS description, 'Mot de passe' as label, 6 as width;
SELECT 'nom' AS name, 'Nom' as label, 6 as width;
SELECT 'prenom' AS name, 'Prénom' as label, 6 as width;
    SELECT 'Téléphone' AS label, 'tel' AS name, 4 as width;
    SELECT 'Courriel' AS label, 'courriel' AS name, 4 as width;
SELECT 'groupe' AS name, 'Permissions' as label, 'select' as type, 4 as width,
    0        as value,
    '[{"label": "Consultant", "value": 1}, {"label": "Éditeur", "value": 2}, {"label": "administrateur", "value": 3}]' as options;

