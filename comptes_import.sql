SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

select 
    'form'       as component,
    'CSV import' as title,
    'Envoyer'  as validate,
    './comptes_upload.sql' as action;
select 
    'comptes_data_input' as name,
    'file'               as type,
    'text/csv'           as accept,
    'Fichier utilisateur'           as label,
    'Envoyer un fichier CSV avec comme colonnes : username, nom, prenom, tel, courriel, groupe, activation' as description,
    TRUE                 as required;

