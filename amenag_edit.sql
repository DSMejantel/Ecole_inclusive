SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'eleves.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
--
-- Set  variables 
SET eleve_edit = (SELECT eleve_id FROM amenag WHERE id = $id);
SET nom_edit = (SELECT nom FROM eleve WHERE id = $eleve_edit);
SET prenom_edit = (SELECT prenom FROM eleve WHERE id = $eleve_edit);
SET amenagements_edit = (SELECT amenagements FROM amenag WHERE id = $id);
SET objectifs_edit = (SELECT objectifs FROM amenag WHERE id = $id);
SET info_edit = (SELECT info FROM amenag WHERE id = $id);

--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la fiche élève' as title,
    'notification.sql?id='||$eleve_edit|| '&tab=Profil' as link,
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
    'amenag_edit_confirm.sql?id='||$id||'&eleve_edit='||$eleve_edit as action,
    'orange'           as validate_color;
    
     SELECT 'Commentaires' AS 'label', 'info2' as name, $info_edit as value,'textarea' as type, 12 as width;
     SELECT 'Aménagements' AS 'label', 'amenagements2' as name, $amenagements_edit as value,'textarea' as type, 6 as width;
     SELECT 'Objectifs' AS 'label', 'objectifs2' as name, $objectifs_edit as value,'textarea' as type, 6 as width;







