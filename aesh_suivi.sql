SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
    
-- écrire le nom de l'AESH dans le titre de la page
SELECT 
    'datagrid' as component;
SELECT 
    'AESH'||' - '||'Quotité : ' || quotite || ' h' as title,
    aesh_name||' '||aesh_firstname as description, 'orange' as color, 1 as active
     FROM aesh WHERE aesh.id = $id;
SELECT 
        tel_aesh as title,
    courriel_aesh as description
      FROM aesh WHERE aesh.id = $id;
   
-- Menu spécifique AESH : modifier
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Modifier' as title,
    'pencil' as icon,
    'orange' as outline,
        $group_id::int<2 as disabled,
    'aesh_edit.sql?id='||$id||'&username='||username as link FROM aesh WHERE aesh.id = $id;
select 
    'Planning' as title,
    'clock-share' as icon,
    'red' as outline,
        $group_id::int<2 as disabled,
    'upload_edt_form.sql?id='||$id as link FROM aesh where aesh.id=$id;

--Onglets
SET tab=coalesce($tab,'Profils');
select 'tab' as component,
TRUE as center;
select  'Profils'  as title, 'briefcase' as icon, 1  as active, 'aesh_suivi.sql?id='||$id||'&tab=Profils' as link, CASE WHEN $tab='Profils' THEN 'orange' ELSE 'green' END as color;
select  'Détails' as title, 'user-plus' as icon, 0 as active, 'aesh_suivi.sql?id='||$id||'&tab=Détails' as link, CASE WHEN $tab='Détails' THEN 'orange' ELSE 'green' END as color;
select  'Liste' as title, 'user-plus' as icon, 1 as active, 'aesh_suivi.sql?id='||$id||'&tab=Liste' as link, CASE WHEN $tab='Liste' THEN 'orange' ELSE 'green' END as color;
select  'Graphique' as title, 'chart-bar' as icon, 1 as active, 'aesh_suivi.sql?id='||$id||'&tab=Graphique' as link, CASE WHEN $tab='Graphique' THEN 'orange' ELSE 'green' END as color;
select  'Carte' as title, 'map-question' as icon, 1 as active, 'aesh_suivi.sql?id='||$id||'&tab=Carte' as link, CASE WHEN $tab='Carte' THEN 'orange' ELSE 'green' END as color; 
select  'Emploi du temps'  as title, 'briefcase' as icon, 1  as active, 'aesh_suivi.sql?id='||$id||'&tab=EDT' as link, CASE WHEN $tab='EDT' THEN 'orange' ELSE 'green' END as color;     

-- Résumé de suivis des élèves
SELECT 'card' as component,
   4 as columns
   WHERE $tab='Profils';
SELECT 
  eleve.nom || ' '|| eleve.prenom ||  ' (' || eleve.classe || ') '  AS title,
  'green' as color, 
  CASE WHEN EXISTS (SELECT eleve.id FROM image WHERE eleve.id=image.eleve_id)
  THEN image_url 
  ELSE './icons/profil.png'
  END as top_image,
  CASE WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id=amenag.eleve_id) 
  THEN 'Mission de l''AESH : '|| ' ' || suivi.mission
  ELSE 'non saisi'
  END  as description,
  group_concat(DISTINCT dispositif.dispo) as footer,
  '[
  ![](./icons/list-check.svg)
](notification.sql?id='||eleve.id||'&tab=Profil) [
    ![](./icons/user-plus.svg)
](notification.sql?id='||eleve.id||'&tab=Suivi)' as footer_md,
  'notification.sql?id='||eleve.id||'&tab=Profil' as link
   FROM eleve INNER JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN amenag on amenag.eleve_id=eleve.id  JOIN dispositif on dispositif.id=affectation.dispositif_id JOIN etab on eleve.etab_id=etab.id JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN image on eleve.id=image.eleve_id JOIN aesh on suivi.aesh_id=aesh.id WHERE aesh_id=$id and $tab='Profils' GROUP BY eleve.id ORDER BY eleve.nom ASC;
   
-- Fiche détaillée
SELECT 'table' as component,   
    'info' as commentaires,
    'amenagements' as Aménagements,
    'objectifs' as Objectifs
    WHERE $tab='Détails';
SELECT 
    eleve.nom||' '||eleve.prenom as élève,
  CASE WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id=amenag.eleve_id) 
     THEN amenag.info
     ELSE 'non saisi'
     END AS commentaires,
  CASE WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id=amenag.eleve_id) 
     THEN amenag.amenagements
     ELSE 'non saisi'
     END AS Aménagements,
  CASE WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id=amenag.eleve_id) 
     THEN amenag.objectifs
     ELSE 'non saisi'
    END  as Objectifs
FROM eleve INNER JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN amenag on amenag.eleve_id=eleve.id  JOIN dispositif on dispositif.id=affectation.dispositif_id JOIN etab on eleve.etab_id=etab.id JOIN suivi on suivi.eleve_id=eleve.id  JOIN aesh on suivi.aesh_id=aesh.id WHERE aesh_id=$id and $tab='Détails' GROUP BY eleve.id ORDER BY eleve.nom ASC;
-- Liste des suivis
SELECT 
    'text' as component,
    'Suivis' as contents
    WHERE $tab='Liste';
SELECT 'table' as component,   
    'Élève' as markdown,
    'nom' as Nom,
    'prenom' as Prénom,
        'temps' as Temps,
        'mut' as mut,
    'classe' as Classe,
    'type' as Niveau,
    'nom_etab' as Établissement,
    1 as sort,
    1 as search
        WHERE $tab='Liste';
    SELECT 
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    suivi.temps as Temps,
       CASE
       WHEN ind=1 THEN 'individuel'
       WHEN mut=2 THEN 'mutualisé'
       END  AS Suivi,
    eleve.classe AS Classe,
    etab.type as Niveau,
    etab.nom_etab AS Établissement,
         '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)' as Élève
  FROM eleve INNER JOIN suivi on suivi.eleve_id=eleve.id FULL JOIN etab on eleve.etab_id = etab.id LEFT JOIN aesh on suivi.aesh_id=aesh.id   WHERE aesh_id = $id and $tab='Liste';      
  
  --Graphique
  SELECT 
    'chart' as component,
    'bar' as type,
    1 as labels,
    1 as stacked,
    0 as horizontal,
    'Répartition du suivi' as title,
    'green' as color,
    'orange' as color,
    'red' as color,
    'indigo' as color,
    'yellow' as color,
    'purple' as color,
    35                    as ymax,
    7                    as yticks,
    1 as toolbar
    WHERE $tab='Graphique';

SELECT 
    eleve.nom ||' '||eleve.prenom ||' ('||eleve.classe||')' as series,
    'Suivis' as x,
    sum(suivi.temps/mut) as value
    FROM eleve INNER JOIN etab on eleve.etab_id = etab.id JOIN suivi on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id WHERE aesh_id = $id and $tab='Graphique' GROUP BY eleve.nom;
SELECT 
    'ULIS' as series,
    'ULIS' as x,
    tps_ULIS as value
    FROM aesh WHERE aesh.id=$id and $tab='Graphique';
SELECT 
    'Activités' as series,
    'Activités' as x,
    tps_mission as value
    FROM aesh WHERE aesh.id=$id and $tab='Graphique';
SELECT 
    'Synthèse(s)' as series,
    'Synthèse(s)' as label,
    tps_synthese as value
    FROM aesh WHERE aesh.id=$id and $tab='Graphique';
    
SELECT 
    'Quotité' as series,
    'Quotité' as x,
    quotite as value
    FROM aesh WHERE aesh.id=$id and $tab='Graphique';

--Carte   
SET AVG_Lat = (SELECT AVG(Lat) FROM etab JOIN eleve on eleve.etab_id = etab.id join suivi on suivi.eleve_id=eleve.id join aesh on suivi.aesh_id=aesh.id  WHERE aesh_id = $id);
SET AVG_Lon = (SELECT AVG(Lon) FROM etab JOIN eleve on eleve.etab_id = etab.id join suivi on suivi.eleve_id=eleve.id join aesh on suivi.aesh_id=aesh.id  WHERE aesh_id = $id);
    SELECT 
    'map' as component,
    'Pôle de Mende' as title,
    12 as zoom,
    400 as height,
    $AVG_Lat as latitude,
    $AVG_Lon as longitude
    where $tab='Carte';

SELECT
    type || ' ' || nom_etab as title,
    Lat AS latitude, 
    Lon AS longitude,
  'etab_notif.sql?id=' || etab.id as link
  FROM etab JOIN eleve on eleve.etab_id = etab.id join suivi on suivi.eleve_id=eleve.id join aesh on suivi.aesh_id=aesh.id  WHERE aesh_id = $id and $tab='Carte';

-- Emploi du temps
select 
    'card' as component,
    1      as columns;
select 
    edt_url as top_image,
    'mis en ligne, le '||strftime('%d/%m/%Y à %Hh%M', created_at) as description
FROM edt WHERE aesh_id = $id and $tab='EDT';

