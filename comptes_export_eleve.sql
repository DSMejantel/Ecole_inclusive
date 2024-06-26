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
    naissance as naissance,
    sexe as sexe,
    INE as INE,
    adresse as adresse,
    code_postal as code,
    commune as commune,
    etab_id as etab_id,
    classe as classe,
    niveau as niveau
  FROM eleve ORDER BY eleve.nom ASC;  



