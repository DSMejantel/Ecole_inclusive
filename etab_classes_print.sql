SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'etablissement.sql?restriction' AS link
FROM eleve WHERE (SELECT user_info.etab FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') and user_info.etab<>$id);


-- Créer une table temporaire avec les classes de l'établissement
DROP VIEW IF EXISTS classes;

CREATE TEMPORARY VIEW classes AS
  SELECT 
  eleve.classe as classe,
  eleve.etab_id as etab
  FROM eleve
  JOIN etab ON etab.id=eleve.etab_id
  GROUP BY eleve.classe;

SELECT 'dynamic' AS component, json_object(
    'component', 'shell',
    'title', 'Fiche de la classe : '||$classe_select,
    'layout','fluid',
    'font_size','14',
    'language', 'fr-FR',
    'link', '/',
    'menu_item', json_array(
            
        json_object(
            'link', classes.etab,
            'title', 'Liste des classes pour : '||etab.nom_etab,
            'submenu', (
                select json_group_array(
                    json_object(
                        'link', 'etab_classes_print.sql?id=' || $id ||'&classe_select='|| classes.classe,
                        'title', classes.classe
                    )
                )  FROM classes AS submenu
WHERE classes.etab = $id 
                
              )
        ),
        json_object(
            'link', 'etab_classes.sql?id=' || $id ||'&classe_select='|| $classe_select,
            'title', 'Retour'
        )
    )
) AS properties
FROM classes join etab on classes.etab=etab.id 
WHERE classes.etab = $id order by classes.classe;

-- Message si utilisateur CAS 
SELECT 'alert' as component,
    'Information' as title,
    'Vous pouvez sélectionner la classe dans le menu déroulant en haut à droite.' 
    as description_md,
    'alert-circle' as icon,
    TRUE as dismissible,
    'red' as color
WHERE $classe_select=0;

-- Liste
  SELECT 'table' as component, 
    TRUE    as hover,
    TRUE    as striped_rows,
    TRUE    as small;
    SELECT 
    eleve.nom||' '||eleve.prenom as élève,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,    
    amenag.info AS commentaires,
    amenag.amenagements AS Aménagements,
    amenag.objectifs AS Objectifs
  FROM eleve LEFT JOIN etab on eleve.etab_id = etab.id LEFT JOIN amenag on amenag.eleve_id=eleve.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.etab_id=$id and eleve.classe=$classe_select GROUP BY amenag.id ORDER BY eleve.nom ASC;  
  
/*  -- Sous-menu / bascule
select 
    'button' as component,
    'sm'     as size,
    --'pill'   as shape,
    'center' as justify;
select 
    'Retour' as title,
    'etab_classes.sql?id=' || $id ||'&classe_select='|| $classe_select as link,
    'users-group' as icon,
    'green' as outline;
*/
