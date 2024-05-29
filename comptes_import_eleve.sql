SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

select 
    'form'       as component,
    'Importer des élèves' as title,
    'Envoyer'  as validate,
    './comptes_upload_eleve.sql' as action;
select
    'etablissement_id' AS name, 'Établissement de l''extraction ONDE ou SIÈCLE' as label, 'select' as type, 6 as width, json_group_array(json_object("label", nom_etab, "value", id)) as options FROM (select nom_etab, id FROM etab union all
   select 'Aucun' as label, NULL as value
 ORDER BY nom_etab ASC);
select 
    'comptes_data_input' as name,
    'file'               as type,
    'text/csv'           as accept,
    'Fichier de mise à jour des élèves'           as label,
    'Envoyer un fichier CSV avec ces colonnes séparées par des virgules et encodé en UTF-8 : nom, prenom, naissance, sexe, INE, adresse, code_postal, commune, classe, niveau' as description,
    TRUE                 as required;


-- Télécharger les données
select 
    'divider' as component,
    'Outils d''importations'   as contents;
SELECT 
    'csv' as component,
    'Exporter le fichier des élèves ' as title,
    'eleves' as filename,
    'file-download' as icon,
    'green' as color;
SELECT 
    nom as nom,
    prenom as prenom,
    naissance as naissance,
    sexe as sexe,
    INE as INE,
    adresse as adresse,
    code_postal as code_postal,
    commune as commune,
    classe as classe,
    niveau as niveau
  FROM eleve ORDER BY eleve.nom ASC; 
  
SELECT 
    'csv' as component,
    'Nomenclature des Niveaux de classe ' as title,
    'niveaux' as filename,
    'file-download' as icon,
    'green' as color;
SELECT 
    niv as niveaux
  FROM niveaux ORDER BY niv ASC; 
  
SELECT 
    'csv' as component,
    'Codes des établissements ' as title,
    'etablissements' as filename,
    'file-download' as icon,
    'green' as color;
SELECT 
    id as etab_id,
    UAI as UAI,
    type as type,
    nom_etab as établissement
  FROM etab ORDER BY id ASC; 
