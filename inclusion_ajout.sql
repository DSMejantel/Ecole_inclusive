SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?restriction&id='||$id AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la fiche élève' as title,
    'notification.sql?id='||$id|| '&tab=Profil' as link,
    'arrow-back-up' as icon,
    'green' as outline
    FROM eleve WHERE eleve.id = $id;     
  
-- écrire le nom de l'élève dans le titre de la page
SELECT 
    'datagrid' as component,
    CASE WHEN EXISTS (SELECT eleve.id FROM image WHERE eleve.id=image.eleve_id)
  THEN image_url 
  ELSE './icons/profil.png'
  END as image_url,
    UPPER(nom) || ' ' || prenom as title
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id;
SELECT 
    'né(e) le :' as title,
    strftime('%d/%m/%Y',eleve.naissance)   as description, 'black' as color,
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
  
   
SELECT 
    'form' as component,
    'Enregistrer' as validate,
    'inclusion_confirm.sql?id='||$id||'&eleve_edit='||$id as action,    
    'orange'           as validate_color;
    
SELECT 'inc[]' as name, 'classes d''inclusion' as label, 6 as width, 'select' as type, TRUE as required, TRUE as multiple, TRUE as dropdown,
     'Les classes connues sont déjà sélectionnées.' as description,
     json_group_array(json_object("label", classe, 
     "value", structure.id,
     'selected', inclusion.classe_id is not null
     )) as options  
     FROM structure
     Left Join inclusion on inclusion.classe_id=structure.id 
     AND inclusion.eleve_id=$id WHERE structure.etab_id=(SELECT etab_id from eleve WHERE eleve.id=$id);

--Bouton supprimer le dispositif
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'supprimer toutes les inclusions' as title,
    'inclusion_delete_confirm.sql?id='||$id||'&eleve_edit='||$id as link,
    'trash' as icon,
    'red' as outline;    


