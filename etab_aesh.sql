SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'etablissement.sql?restriction' AS link
FROM eleve WHERE (SELECT user_info.etab FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') and user_info.etab<>$id);

--Menu
SELECT 'dynamic' AS component, 
CASE WHEN $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties; 

-- basculer vers notifications / suivis
select 
    'button' as component,
    'sm'     as size,
    --'pill'   as shape,
    'center' as justify;
select 
    'AESH' as title,
    'user-plus' as icon,
    'orange' as color
    WHERE $group_id>1;
select 
    'Suivis' as title,
    'etab_suivi.sql?id=' || $id  ||'&tab=Acc' as link,
    'list-check' as icon,
    'orange' as outline;
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
select 
    'Notifications' as title,
    'etab_notif.sql?id=' || $id as link,
    'certificate' as icon,
    'orange' as outline;
select 
    'Examens' as title,
    'etab_examen.sql?id=' || $id as link,
    'school' as icon,
    'orange' as outline;
select 
    'Carte' as title,
    'etab_carte.sql?id=' || $id as link,
    'map' as icon,
    'teal' as outline;
select 
    'Stats' as title,
    'etab_stats.sql?id=' || $id as link,
    'chart-histogram' as icon,
    'teal' as outline;
select 
    'Photos' as title,
    'etab_trombi.sql?id=' || $id as link,
    'camera' as icon,
    'teal' as outline;



-- Set a variable 
SET NB_eleve = (SELECT count(distinct eleve.id) FROM eleve where eleve.etab_id=$id);

SET NB_accomp_notif = (SELECT count(distinct notif.eleve_id) FROM notif JOIN eleve on notif.eleve_id=eleve.id JOIN modalite on modalite.id=notif.modalite_id  JOIN notification on notification.eleve_id = eleve.id WHERE eleve.etab_id=$id AND modalite.type LIKE '%AESH%'  and datefin > date('now'));
SET NB_accomp = (SELECT count(distinct suivi.eleve_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id);

SET NB_notif = (SELECT count(notification.id) FROM notification JOIN eleve on notification.eleve_id = eleve.id WHERE eleve.etab_id=$id);

SET NB_aesh = coalesce((SELECT count(distinct suivi.aesh_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id),(SELECT count(distinct suivi.aesh_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id));
SET NB_accomp_ind = (SELECT count(distinct suivi.eleve_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id and suivi.ind=1);
SET NB_accomp_mut = $NB_accomp-$NB_accomp_ind;
SET TPS_suivi_ind=(SELECT sum(distinct(suivi.temps*ind)) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id);
SET TPS_suivi_ext=(SELECT sum((suivi.temps)) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id JOIN aesh on aesh.id=suivi.aesh_id JOIN user_info on user_info.username=aesh.username WHERE eleve.etab_id<>$id and user_info.etab=$id);
SET TPS_suivi_rec=(SELECT sum((suivi.temps)) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id JOIN aesh on aesh.id=suivi.aesh_id JOIN user_info on user_info.username=aesh.username WHERE eleve.etab_id=$id and user_info.etab<>$id);
SET AESH_quot=coalesce((SELECT sum(aesh.quotite) FROM aesh join user_info on user_info.username=aesh.username where user_info.etab=$id),0)-coalesce($TPS_suivi_ext,0) + coalesce($TPS_suivi_rec,0);
SET AESH_synt=(SELECT sum(aesh.tps_synthese) FROM aesh join user_info on user_info.username=aesh.username where user_info.etab=$id);
SET AESH_mission=(SELECT sum(aesh.tps_mission) FROM aesh join user_info on user_info.username=aesh.username where user_info.etab=$id);
SET AESH_ULIS=(SELECT sum(aesh.tps_ULIS) FROM aesh join user_info on user_info.username=aesh.username where user_info.etab=$id);
SET Ratio_mut = ($AESH_quot -coalesce($AESH_synt,0) -coalesce($TPS_suivi_ind,0) -coalesce($AESH_mission,0) - coalesce($AESH_ULIS,0))/$NB_accomp_mut;
SET Ratio_brut = ($AESH_quot -coalesce($TPS_suivi_ind,0))/($NB_accomp_notif-$NB_accomp_ind);


-- écrire les infos de l'établissement dans le titre de la page [GRILLE]
SELECT 
    'datagrid' as component,
    type || ' ' || nom_etab as title FROM etab WHERE id = $id;
SELECT 
    ' Élèves avec suivi notifié : ' as title,
    $NB_accomp_notif as description,
    'certificate' as icon;
SELECT 
    ' Élèves accompagnés : ' as title,
    $NB_accomp as description,
    'user-plus' as icon;
SELECT 
    ' Suivis individuels : ' as title,
    $NB_accomp_ind as description,
    'box-multiple-1' as icon;
SELECT 
    ' Suivis mutualisés : ' as title,
    $NB_accomp_mut as description,
    'box-multiple-2' as icon;
    
SELECT 
' AESH ' as title,
    $NB_aesh as description,
    TRUE           as active,
    'user-plus' as icon;
SELECT 
' Quotité totale disponible' as title,
    $AESH_quot||' (et '||coalesce($TPS_suivi_ext,0)||' hors établissement)' as description,
    --TRUE           as active,
    'clock' as icon;
SELECT 
' Temps de suivi individuel ' as title,
    $TPS_suivi_ind as description,
    TRUE           as active,
    'clock' as icon;
SELECT 
' Heures brutes mutualisables par élève notifié (hors accompagnement individuel) ' as title,
    printf("%.2f",$Ratio_brut) as description,
    TRUE           as active,
    'clock-question' as icon;
SELECT 
' Heures nettes par élève sur accompagnements mutualisés ' as title,
    printf("%.2f",$Ratio_mut) as description,
    TRUE           as active,
    'clock-question' as icon;

-- Liste des AESH
select 
    'divider' as component,
    'Liste des AESH' as contents,
    'orange' as color;


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
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils "Fiche AESH")' as Actions
  FROM suivi LEFT JOIN aesh on suivi.aesh_id=aesh.id JOIN eleve on suivi.eleve_id=eleve.id JOIN etab on eleve.etab_id = etab.id WHERE eleve.etab_id=$id GROUP BY aesh.aesh_name;  
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
        FROM eleve JOIN etab on eleve.etab_id = etab.id JOIN suivi on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id  ORDER BY eleve.nom ASC;
*/
--
-- create a temporary table to preprocess the data

create temporary table if not exists TAB_suivi(etab_id,aesh_id,aesh_firstname,aesh_name,eleve_id,prenom,nom,classe,temps decimal,mut decimal,numero INTEGER PRIMARY KEY);
delete  from TAB_suivi; 
insert into TAB_suivi(etab_id,aesh_id,aesh_firstname,aesh_name,eleve_id,prenom,nom,classe,temps,mut)
SELECT $id, aesh.id, aesh.aesh_firstname, aesh_name,eleve.id, eleve.prenom, eleve.nom,eleve.classe, suivi.temps, suivi.mut FROM eleve JOIN etab on eleve.etab_id = etab.id JOIN suivi on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id ORDER BY aesh.id,eleve.id;;

--select 'table' as component;
--select * from TAB_suivi;

-- Graphique Bulle
select 
    'chart'               as component,
    'Répartitions des suivis' as title,
    'bubble'             as type,
    500 as height,
    1 as toolbar,
    --'N° Élève'as xtitle,
    --'N° AESH' as ytitle,
    'Heures' as ztitle,
    400 as height,
    min(numero)-1                     as xmin,
    max(numero)+1                    as xmax,
    min(aesh_id)-1                    as ymin,
    max(aesh_id)+1                  as ymax,
    0                     as zmin,
    1000                   as zmax,
    0                    as xticks,
    0                    as yticks,
    35                    as zticks
    FROM TAB_suivi WHERE etab_id=$id;
   
select 
    SUBSTR(aesh_firstname, 1, 1) ||'. '|| aesh_name||' --> '||SUBSTR(prenom, 1, 1) ||'. '||nom as series,
    coalesce(numero,0) as label,
    coalesce(aesh_id,0) as y,    
    coalesce(temps,0)        as z
    FROM TAB_suivi WHERE etab_id=$id ORDER BY aesh_id,eleve_id;
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
    SUBSTR(aesh_firstname, 1, 1) ||'. '|| aesh_name as label,
    SUBSTR(prenom, 1, 1) ||'. '||nom||' ('||classe||')' as series,
    sum((temps*1.00)/mut) as value
        FROM TAB_suivi WHERE etab_id=$id GROUP BY aesh_id,eleve_id ORDER BY aesh_name DESC; 
         
