SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties; 

-- basculer vers notifications / suivis
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'Carte' as title,
    'etab_carte.sql?id=' || $id as link,
    'map' as icon,
    'orange' as outline;
select 
    'Stats' as title,
    'etab_stats.sql?id=' || $id as link,
    'chart-histogram' as icon,
    'orange' as outline;
select 
    'Photos' as title,
    'etab_trombi.sql?id=' || $id as link,
    'camera' as icon,
    'orange' as outline;
select 
    'Notifications' as title,
    'etab_notif.sql?id=' || $id as link,
    'certificate' as icon,
    'orange' as outline;
select 
    'Suivis' as title,
    'etab_suivi.sql?id=' || $id  ||'&tab=Acc' as link,
    'list-check' as icon,
    'orange' as outline;
select 
    'AESH' as title,
    'user-plus' as icon,
    'orange' as color;
select 
    'Classes' as title,
    'etab_classes.sql?id=' || $id as link,
    'users-group' as icon,
    'orange' as outline;
select 
    'Dispositifs' as title,
    'etab_dispositifs.sql?id=' || $id as link,
    'lifebuoy' as icon,    
    'orange' as outline;

-- Set a variable 
SET NB_eleve = (SELECT count(distinct eleve.id) FROM eleve where eleve.etab_id=$id);
SET NB_accomp = (SELECT count(distinct suivi.eleve_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE suivi.aesh_id<>1 and eleve.etab_id=$id);
SET NB_notif = (SELECT count(notification.id) FROM notification JOIN eleve on notification.eleve_id = eleve.id WHERE eleve.etab_id = $id);
SET NB_aesh = (SELECT count(distinct suivi.aesh_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id and suivi.aesh_id<>1);

-- écrire les infos de l'établissement dans le titre de la page [GRILLE]
SELECT 
    'datagrid' as component,
    type || ' ' || nom_etab as title FROM etab WHERE id = $id;
SELECT 
    ' Élèves accompagnés : ' as title,
    $NB_accomp as description,
    'briefcase' as icon;
SELECT 
    ' Élèves à suivre : ' as title,
    $NB_eleve as description,
    'briefcase' as icon;
SELECT 
' AESH ' as title,
    $NB_aesh as description,
    TRUE           as active,
    'user-plus' as icon;



-- Liste des AESH
select 
    'button' as component,
    'lg'     as size,
    'center' as justify,
    'pill'   as shape;
select 
    'Liste des AESH' as title,
    'user-plus' as icon,
    'warning' as outline;

SELECT 'table' as component,   
    'Actions' as markdown,
    'aesh.aesh_name' as Nom,
    1 as sort,
    1 as search;
    SELECT 
    aesh.aesh_name as Nom,
    aesh.aesh_firstname as Prénom,
   aesh.quotite AS Quotité,
   sum((suivi.temps)*2/mut)/2 AS Suivis,
   sum(distinct(suivi.temps*ind)) AS Individuel,  
   coalesce(sum(distinct(aesh.tps_ULIS)),0) as ULIS, 
   coalesce(sum(distinct(aesh.tps_mission)),0) as Activités,
   coalesce(sum(distinct(aesh.tps_synthese)),0) as Synthèse,
   aesh.quotite-sum((suivi.temps)*2/mut)/2-sum(distinct(aesh.tps_ULIS))-sum(distinct(aesh.tps_mission))-sum(distinct(aesh.tps_synthese)) AS Écart,
   CASE WHEN aesh.quotite=sum((suivi.temps)*2/mut)/2+tps_synthese+tps_mission+tps_ULIS
   THEN 'green' 
   WHEN aesh.quotite>sum((suivi.temps)*2/mut)/2+tps_synthese+tps_mission+tps_ULIS
   THEN 'orange' 
   ELSE 'red'
   END as _sqlpage_color,
         '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils)' as Actions
  FROM suivi LEFT JOIN aesh on suivi.aesh_id=aesh.id JOIN eleve on suivi.eleve_id=eleve.id JOIN etab on eleve.etab_id = etab.id WHERE eleve.etab_id=$id and aesh.id<>1 GROUP BY aesh.aesh_name;  
/*
-- Graphique
select 
    'chart'               as component,
    'Répartitions des suivis' as title,
    'scatter'             as type,
    1 as toolbar,
    12                     as marker,
    'Élève'         as xtitle,
    'Heures' as ytitle,
    0                     as xmin,
    6                    as xmax,
    0                     as ymin,
    35                    as ymax,
    1                     as zmin,
    35                   as zmax,
    6                    as xticks,
    10                    as yticks,
    35                    as zticks;
   
select 
    SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '|| aesh_name as series,
    SUBSTR(eleve.prenom, 1, 1) ||'. '||eleve.nom as x,
    suivi.temps        as y
        FROM eleve JOIN etab on eleve.etab_id = etab.id JOIN suivi on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id and aesh.id>1  ORDER BY eleve.nom ASC;
*/

-- Graphique Bulle
select 
    'chart'               as component,
    'Répartitions des suivis' as title,
    'bubble'             as type,
        500 as height,
    1 as toolbar,
    'N° Élève'as xtitle,
    'N° AESH' as ytitle,
    'Heures' as ztitle,
    400 as height,
    min(eleve.id)-2                     as xmin,
    max(eleve.id)+2                    as xmax,
    min(aesh.id)-2                    as ymin,
    max(aesh.id)+2                  as ymax,
    0                     as zmin,
    1000                   as zmax,
    6                    as xticks,
    12                    as yticks,
    35                    as zticks
    FROM eleve JOIN etab on eleve.etab_id = etab.id JOIN suivi on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id and aesh.id>1 ;
   
select 
    SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '|| aesh_name as series,
    coalesce(eleve.id,0) as x,
    coalesce(aesh.id,0) as y,    
    --SUBSTR(eleve.prenom, 1, 1) ||'. '||eleve.nom as labels,
    coalesce(suivi.temps,0)        as z
        FROM eleve JOIN etab on eleve.etab_id = etab.id JOIN suivi on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id and aesh.id>1 ;
/*     
-- Graphique Barres Elèves
select 
    'chart'               as component,
    'Répartitions des suivis par élève' as title,
    'bar'             as type,
    500 as height,
    1 as toolbar,
    1 as stacked,
    400 as height,
    'Élève'         as xtitle,
    'heures' as ytitle,
    0                     as xmin,
    50                    as xmax,
    0                     as ymin,
    35                   as ymax,
    15                    as xticks,
    7                    as yticks;

   
select 
    SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '|| aesh_name as series,
    SUBSTR(eleve.prenom, 1, 1) ||'. '||eleve.nom as x,
    sum(suivi.temps)        as y
        FROM eleve JOIN etab on eleve.etab_id = etab.id JOIN suivi on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id and aesh.id>1 GROUP BY eleve.id ORDER BY eleve.id ASC;
*/
-- Graphique Barres AESH
select 
    'chart'               as component,
    500 as height,
    'Répartitions des suivis par AESH' as title,
    'bar'             as type,
    0 as labels,
    1 as stacked,
    1 as toolbar,
    'AESH'         as xtitle,
    'heures' as ytitle,
    15                     as xmin,
    30                    as xmax,
    0                     as ymin,
    35                   as ymax,
    15                    as xticks,
    7                    as yticks;

   
select 
    SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '|| aesh_name as label,
    SUBSTR(eleve.prenom, 1, 1) ||'. '||eleve.nom||' ('||eleve.classe||')' as series,
    sum(suivi.temps/mut)        as value
        FROM suivi JOIN etab on eleve.etab_id = etab.id JOIN eleve on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id and aesh.id>1 GROUP BY suivi.id ORDER BY aesh.id ASC; 
         
