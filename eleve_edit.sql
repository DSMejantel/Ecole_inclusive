SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

-- Ouverture exceptionnelle de droits pour le professeur principal de la classe          
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username join eleve WHERE login_session.id = sqlpage.cookie('session') and user_info.classe<>eleve.classe and eleve.id=$id),3);

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

   -- Mettre à jour l'élève modifié dans la base
   SET edition = (SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') )
SET modif = (SELECT current_timestamp)
 UPDATE eleve SET nom=$nom, prenom=$prenom, naissance=$naissance, classe=$classe, etab_id=:Établissement, niveau=:Niveau, referent_id=:Référent, comm_eleve=$comm_eleve, modification=$modif, editeur=$edition WHERE id=$id and $prenom is not null
 returning 
'redirect' AS component,
'notification.sql?id='||$id||'&tab=Profil' as link;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
--
-- Set a variable 
SET id_edit = (SELECT nom FROM eleve WHERE id = $id);
SET nom_edit = (SELECT nom FROM eleve WHERE id = $id);
SET prenom_edit = (SELECT prenom FROM eleve WHERE id = $id);
SET naissance_edit = (SELECT naissance FROM eleve WHERE id = $id);
SET etab_edit = (SELECT etab_id FROM eleve WHERE id = $id);
SET niv_edit = (SELECT niveau FROM eleve WHERE id = $id);
SET classe_edit = (SELECT classe FROM eleve WHERE id = $id);
SET referent_edit = (SELECT referent_id FROM eleve WHERE id = $id);
SET comm_edit = (SELECT comm_eleve FROM eleve WHERE id = $id); 

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
    CASE WHEN classe<>''
    THEN 'Classe : ' || classe 
    ELSE 'Niveau : ' || (SELECT niv FROM niveaux JOIN eleve on niveaux.niv=eleve.niveau)
    END as description,
    1 as active, 'green' as color,
    'etab_classes.sql?id='||etab.id||'&classe_select='||eleve.classe as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id WHERE eleve.id = $id;


    SELECT 
    'form' as component,
    'Mettre à jour' as validate,
    'orange'           as validate_color;
       
    SELECT 'Nom' AS label, 'user' as prefix_icon, 'nom' AS name, $nom_edit as value, 5 as width, TRUE as required;
    SELECT 'Prénom' AS label, 'user' as prefix_icon, 'prenom' AS name, $prenom_edit as value, 4 as width, TRUE as required;
    SELECT 'Date de naissance' AS label, 'calendar-month' as prefix_icon, 'naissance' AS name, 'date' as type, $naissance_edit as value, 3 as width;
    SELECT 'Établissement' AS name, 4 as width, 
          $etab_edit::integer as value,
    'select' as type, json_group_array(json_object("label", nom_etab, "value", etab.id)) as options FROM etab;
    SELECT 'Niveau' AS name, 'select' as type, 2 as width, $niv_edit as value, json_group_array(json_object("label", niv, "value", niv)) as options FROM (select * FROM niveaux ORDER BY niv ASC);
    SELECT 'Classe' AS label, 'users-group' as prefix_icon, 'classe' AS name, $classe_edit as value, 2 as width;
    SELECT 'Référent' AS name, 'select' as type, 4 as width, $referent_edit::integer as value,
    json_group_array(json_object("label", nom_ens_ref, "value", id)) as options FROM referent;
    SELECT 'Commentaire' AS label, 'comm_eleve' AS name, $comm_edit as value,'textarea' as type, 12 as width;
    

 

