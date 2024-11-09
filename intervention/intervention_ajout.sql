SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Ouverture exceptionnelle de droits pour le professeur principal de la classe        
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username join eleve WHERE login_session.id = sqlpage.cookie('session') and eleve.id=$id and user_info.classe<>eleve.classe), (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username join eleve WHERE login_session.id = sqlpage.cookie('session') and eleve.id=$id and user_info.classe is null), (coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE login_session.id = sqlpage.cookie('session') and $coordo=1),3)));

-- Ouverture exceptionnelle de droits pour l'équipe des réunions de synthèse        
SET classe_eleve_id = (SELECT structure.id FROM structure JOIN eleve WHERE eleve.etab_id=structure.etab_id and eleve.classe=structure.classe and eleve.id=$id);
SET group_synthese = coalesce((SELECT equipe_synthese.classe_id FROM equipe_synthese LEFT join user_info on  user_info.username=equipe_synthese.username  LEFT join login_session on user_info.username=login_session.username WHERE login_session.id = sqlpage.cookie('session') and equipe_synthese.classe_id=$classe_eleve_id), 0);

SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<3 AND $group_synthese=0;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- écrire le nom de l'élève dans le titre de la page
SELECT 
    'datagrid' as component,
    CASE WHEN EXISTS (SELECT eleve.id FROM image WHERE eleve.id=image.eleve_id)
  THEN '../'||image_url 
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
    
-- Formulaire pour ajouter une intervention
SELECT 'form' as component, 
    'Noter un événement dans l''historique' as title, 
    '../etab_synthese_classe.sql?etab='||$etab||'&classe='||$classe||'&id='||$id|| '&ajout=1' as action,
    'Ajouter' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;
    
    SELECT 'Date' AS label, 'horodatage' AS name, 'date' as type, (select date('now')) as value, 4 as width;
    SELECT 'Nature' AS label, 'nature' AS name, 'select' as type,'[{"label": "ESS", "value": "ESS"}, {"label": "Synthèse", "value": "Synthèse"},{"label": "Info", "value": "Info"}, {"label": "RDV", "value": "RDV"}, {"label": "Tel", "value": "Tel"}, {"label": "Courrier", "value": "Courrier"}]' as options, 4 as width;
    SELECT 'Important' AS label, 'important' AS name, 'checkbox' as type, 1 as value, 2 as width; 
    SELECT 'Masqué' AS label, 'verrou' AS name, 'checkbox' as type, 1 as value, 2 as width; 
    SELECT 'Notes' AS label, 'notes' AS name, 'textarea' as type, 12 as width;




    


