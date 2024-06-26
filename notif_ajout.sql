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
    'notification.sql?id='|| $id ||'&tab=Notification' as link,
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

    
-- Formulaire pour ajouter une notification
SELECT 'form' as component, 
'Ajouter une notification' as title, 
'notification.sql?id='|| $id ||'&tab=Notification' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;

SELECT 'Origine' AS 'label', 'select' as type, '[{"label": "MDPH", "value": 0}, {"label": "CDAO", "value": 1}]' as options, 'origine' AS name, 3 as width;
SELECT 'Département' AS 'label', 'world' as prefix_icon, 'text' as type, 'dpmt' AS name, 3 as width; 
SELECT 'Début' AS 'label', 'calendar-up' as prefix_icon, 'date' as type, 'datedeb' AS name, 3 as width;
SELECT 'Fin' AS 'label', 'calendar-down' as prefix_icon, 'date' as type, 'datefin' AS name, 3 as width;
SELECT 'Droits ouverts pour :' AS 'label', 'modalite[]' as name, 6 as width, 'select' as type, true as multiple, true as dropdown, json_group_array(json_object("label", type, "value", id)) as options FROM (select * FROM modalite ORDER BY type ASC);
SELECT 'Aide pour :' AS 'label', 'lifebuoy' as prefix_icon, 'text' as type, 'acces' AS name, 6 as width, TRUE as required;    

