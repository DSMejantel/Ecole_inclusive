SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

  
--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste' as title,
    'eleves.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;      
select 
    'Retour à la fiche élève' as title,
    'notification.sql?id='|| $id as link,
    'briefcase' as icon,
    'green' as outline;  
    
-- écrire le nom de l'élève dans le titre de la page
SELECT 
    'datagrid' as component,
    CASE WHEN EXISTS (SELECT eleve.id FROM image WHERE eleve.id=image.eleve_id)
  THEN image_url 
  ELSE './icons/profil.png'
  END as image_url,
    UPPER(nom) || ' ' || prenom as title,
    'INE : '||INE as description
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id;
SELECT 
    adresse||' '||code_postal||' '||commune  as title,
    'né(e) le :'||strftime('%d/%m/%Y',eleve.naissance)   as description, 'black' as color,
    0 as active
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id;
SELECT 
    'Dispositif(s) :' as title,
    1 as active,
    group_concat(DISTINCT dispositif.dispo)   as description, 'orange' as color,
    'etab_dispositifs.sql?id='||etab.id as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id LEFT JOIN affectation on affectation.eleve_id=eleve.id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.id = $id;
select 
    etab.type||' '||etab.nom_etab as title,
    CASE WHEN classe<>''
    THEN 'Classe : ' || classe 
    ELSE 'Niveau : ' || (SELECT niv FROM niveaux JOIN eleve on niveaux.niv=eleve.niveau)
    END as description,
    1 as active, 'green' as color,
    'etab_classes.sql?id='||etab.id||'&classe_select='||eleve.classe as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id WHERE eleve.id = $id;


-- Formulaire pour ajouter une fiche
select 'form' as component, 'Ajouter un document' as title, 'upload_documents.sql?id='||$id as action;
select 'select' as type, 'type' as name, 'Catégorie' as label, '[{"label": "PPRE", "value": "PPRE"}, {"label": "PAP", "value": "PAP"}, {"label": "PAI", "value": "PAI"}, {"label": "Gevasco", "value": "Gevasco"}, {"label": "Notification", "value": "Notification"}, {"label": "Affectation", "value": "Affectation"}, {"label": "Évaluation", "value": "Évaluation"}, {"label": "Autre", "value": "Autre"}]' as options, 6 as width;
select 'date' as type, 'datation' as name, 'Date' as label, TRUE as required, 6 as width;
select 'file' as type, 'doc' as name, 'Document (en pdf)' as label, TRUE as required;


    


