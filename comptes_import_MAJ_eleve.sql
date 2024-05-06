SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter le fichier des élèves ' as title,
    'eleves' as filename,
    'file-download' as icon,
    'green' as color;
SELECT 
    id as id,
    nom as nom,
    prenom as prenom,
    etab_id as etab_id,
    classe as classe,
    niveau as niveau
  FROM eleve ORDER BY eleve.nom ASC;  

select 
    'form'       as component,
    'CSV import' as title,
    'Envoyer'  as validate,
    './comptes_upload_MAJ_eleve.sql' as action;
select 
    'comptes_data_input' as name,
    'file'               as type,
    'text/csv'           as accept,
    'Fichier de mise à jour des élèves'           as label,
    'Envoyer un fichier CSV avec ces colonnes séparées par des virgules : id, nom, prenom, etab_id, classe, niveau' as description,
    TRUE                 as required;

