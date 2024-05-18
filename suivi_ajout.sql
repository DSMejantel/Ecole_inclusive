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
    'notification.sql?id='|| $id || '&tab=Suivi' as link,
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
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id;
SELECT 
    adresse||' '||code_postal||' '||commune as title,
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
    'Classe : ' || classe  as description,
    1 as active, 'green' as color,
    'etab_classes.sql?id='||etab.id||'&classe_select='||eleve.classe as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id WHERE eleve.id = $id;
    
-- Formulaire pour ajouter un suivi
SELECT 'form' as component, 
    'Mettre en place des suivis' as title, 
    'notification.sql?id='||$id|| '&tab=Suivi' as action,
    'Ajouter' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;
SELECT 'AESH' as name, 'select' AS type, 3 as width, json_group_array(json_object("label", aesh_name, "value", id)) as options FROM (select * FROM aesh ORDER BY aesh_name ASC);
     SELECT 'Temps de suivi hebdomadaire' AS label, 'clock' as prefix_icon, 'temps' AS name, 'number' as type, 0.5 as step, 0 as value, 3 as width;     
     SELECT 'mutualisation' as name, 'select' as type, 3 as width, '[{"label": "non", "value": 1}, {"label": "oui", "value": 2}]' as options;
     SELECT 'individuel' as name, 'select' as type, 3 as width, '[{"label": "non", "value": 0}, {"label": "oui", "value": 1}]' as options, 0 as value;
     SELECT 'Mission de l''accompagnant' as label, 'mission' as name, 'textarea' as type, 12 as width;


    


