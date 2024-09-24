SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'eleves.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
--
-- Set  variables 
SET eleve_edit = (SELECT eleve_id FROM suivi WHERE id = $suivi);
SET nom_edit = (SELECT nom FROM eleve WHERE id = $eleve_edit);
SET prenom_edit = (SELECT prenom FROM eleve WHERE id = $eleve_edit);
SET aesh_edit = (SELECT aesh_id FROM suivi WHERE id = $suivi);
SET temps_edit = (SELECT temps FROM suivi WHERE id = $suivi);
SET mut_edit = (SELECT mut FROM suivi WHERE id = $suivi); 
SET ind_edit = (SELECT ind FROM suivi WHERE id = $suivi);
SET mission_edit = (SELECT mission FROM suivi WHERE id = $suivi); 

 
--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la fiche élève' as title,
    '../etab_suivi.sql?id='||$etab||'&tab=Acc#'||$eleve as link,
    'arrow-back-up' as icon,
    'green' as outline;    

-- écrire le nom de l'élève dans le titre de la page / attention variable $eleve
SELECT 
    'datagrid' as component,
    CASE WHEN EXISTS (SELECT eleve.id FROM image WHERE eleve.id=image.eleve_id)
  THEN image_url 
  ELSE './icons/profil.png'
  END as image_url,
    UPPER(nom) || ' ' || prenom as title
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $eleve;
SELECT 
    'né(e) le :' as title,
    strftime('%d/%m/%Y',eleve.naissance)   as description, 'black' as color,
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
  

--- Formulaire de Mise à jour

    SELECT 
    'form' as component,
    'Valider' as validate,
    'suivi_edit_confirm.sql?id='||$suivi||'&etab='||$etab||'&eleve='||$eleve as action,
    'orange'           as validate_color;
    
     SELECT 'AESH' as label, 'AESH2' as name, 3 as width, CAST($aesh_edit as integer) as value, 'select' AS type, 
     json_group_array(json_object("label", username, "value", id)) as options FROM (select * FROM aesh ORDER BY aesh_name ASC);
     SELECT 'Temps de suivi hebdomadaire' AS label, 'clock' as prefix_icon, 'temps2' AS name, 'number' as type, 0.5 as step, $temps_edit as value, 3 as width;     
     SELECT 'mutualisation' as label, 'mutualisation2' as name, 3 as width, CAST($mut_edit as integer) as value,'select' as type, '[{"label": "non", "value": 1}, {"label": "oui", "value": 2}]' as options;
     SELECT 'individuel' as label, 'individuel2' as name, 3 as width, CAST($ind_edit as integer) as value,'select' as type, '[{"label": "non", "value": 0}, {"label": "oui", "value": 1}]' as options;
     SELECT 'Mission de l''accompagnant' as label, 'mission2' as name, 'textarea' as type, $mission_edit as value, 12 as width;

 


