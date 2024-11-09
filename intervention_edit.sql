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
    'notification.sql?id='|| $eleve || '&tab=Historique' as link,
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
    'Sexe : '||sexe||' - INE : '||INE as description
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $eleve;
SELECT 
    adresse||' '||code_postal||' '||commune as title,
    'né(e) le :'||strftime('%d/%m/%Y',eleve.naissance)   as description, 'black' as color,
    0 as active
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $eleve;
SELECT 
    'Dispositif(s) :' as title,
    1 as active,
    group_concat(DISTINCT dispositif.dispo)   as description, 'orange' as color,
    'etab_dispositifs.sql?id='||etab.id as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id LEFT JOIN affectation on affectation.eleve_id=eleve.id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.id = $eleve;
select 
    etab.type||' '||etab.nom_etab as title,
    'Classe : ' || classe  as description,
    1 as active, 'green' as color,
    'etab_classes.sql?id='||etab.id||'&classe_select='||eleve.classe as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id WHERE eleve.id = $eleve;

-- Set a variable 
SET date_edit = (SELECT horodatage FROM intervention WHERE id = $id);
SET nature_edit = (SELECT nature FROM intervention WHERE id = $id);
SET imp_edit = (SELECT tracing FROM intervention WHERE id = $id);
SET notes_edit = (SELECT notes FROM intervention WHERE id = $id);
    
-- Formulaire pour modifier une intervention
SELECT 'form' as component, 
    'Noter un événement dans l''historique' as title, 
    'notification.sql?id='||$eleve||'&intervention_id='||$id||'&tab=Historique&intervention=2' as action,
    'Mettre à jour' as validate,
    'green'           as validate_color;
    
    SELECT 'Date' AS label, 'horodatage' AS name, 'date' as type, $date_edit as value, 4 as width;
    SELECT 'Nature' AS label, 'nature' AS name, 'select' as type,'[{"label": "ESS", "value": "ESS"}, {"label": "Synthèse", "value": "Synthèse"}, {"label": "Info", "value": "Info"}, {"label": "RDV", "value": "RDV"}, {"label": "Tel", "value": "Tel"}, {"label": "Courrier", "value": "Courrier"}]' as options, $nature_edit as value, 4 as width;
    SELECT 'Important' AS label, 'important' AS name, tracing=1 as checked, 'checkbox' as type, 1 as value, 4 as width FROM intervention WHERE id = $id; 
    SELECT 'Notes' AS label, 'notes' AS name, 'textarea' as type, $notes_edit as value, 12 as width;




    


