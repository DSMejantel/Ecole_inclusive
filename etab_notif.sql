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

select 
    'button' as component,
    'sm'     as size,
    --'pill'   as shape,
    'center' as justify;
select 
    'AESH' as title,
    'etab_aesh.sql?id=' || $id as link,
    'user-plus' as icon,
    'orange' as outline
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
    'certificate' as icon,
    'orange' as color;
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
SET NB_eleve = (SELECT count(distinct eleve.id) FROM notification INNER JOIN eleve on eleve.id=notification.eleve_id where eleve.etab_id=$id);
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
    TRUE           as active,
    'briefcase' as icon;
SELECT 
    ' Élèves notifiés : ' as title,
    $NB_eleve as description,
    'briefcase' as icon;
SELECT 
' AESH ' as title,
    $NB_aesh as description,
    'user-plus' as icon;


-- Liste des notifications
-- create a temporary table to preprocess the data
create temporary table if not exists Etab_notif(notif_id, eleve_id, droits_ouverts, droits_fermes, ens_ref, datefin);
delete  from Etab_notif; 
insert into Etab_notif
SELECT 
notification.id notif_id,
notification.eleve_id as eleve_id,
CASE WHEN datefin>datetime(date('now')) THEN group_concat(DISTINCT modalite.type) ELSE '-' END as droits_ouverts,
CASE WHEN datefin<datetime(date('now')) THEN group_concat(DISTINCT modalite.type) ELSE '-' END as droits_fermes,
SUBSTR(referent.prenom_ens_ref, 1, 1) ||'. '||referent.nom_ens_ref as ens_ref,
datefin as datefin
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id Where eleve.etab_id=$id group by notification.id;

select 
    'divider' as component,
    'Liste des Notifications' as contents,
    'orange' as color;


SELECT 'table' as component,
    'Actions' as markdown,
    'Fin_de_droit' as markdown,
    1 as sort,
    1 as search;
SELECT 
  CASE
       WHEN (SELECT max(datefin) FROM notification WHERE notification.eleve_id=eleve.id) < datetime(date('now', '+1 day')) THEN 'red'
       WHEN (SELECT max(datefin) FROM notification WHERE notification.eleve_id=eleve.id) < datetime(date('now', '+350 day')) THEN 'orange'
       ELSE 'green'
    END AS _sqlpage_color,
      eleve.nom as Nom,
      eleve.prenom as Prénom,
    group_concat(distinct Etab_notif.droits_ouverts) as Droits,
    CASE
       WHEN group_concat(distinct Etab_notif.droits_fermes) <> '-' THEN   '[
    ![](./icons/alert-octagon.svg)
](/ "Fin de droit pour : '||group_concat(distinct Etab_notif.droits_fermes)||'")' 
    ELSE '' END as Fin_de_droit,
  Etab_notif.ens_ref as Référent,
  strftime('%d/%m/%Y',(SELECT max(datefin) FROM notification WHERE notification.eleve_id=eleve.id)) AS Fin,
CASE
       WHEN EXISTS (SELECT eleve.id FROM affectation 
    WHERE eleve.id = affectation.eleve_id) 
THEN
'[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)' 
ELSE
'[
    ![](./icons/alert-triangle-filled.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)' 
END as Actions 
FROM etab INNER JOIN eleve on eleve.etab_id=etab.id JOIN Etab_notif on eleve.id=Etab_notif.eleve_id WHERE etab.id = $id
GROUP BY eleve.id ORDER BY eleve.nom ASC;  

-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter' as title,
    'eleves_etablissement' as filename,
    'file-download' as icon,
    'green' as color;
SELECT 
     eleve.nom as Nom,
      eleve.prenom as Prénom,
  group_concat(DISTINCT modalite.type) as Droits,
  etab.nom_etab as Établissement,
  nom_ens_ref as Référent,
  datefin AS Fin  
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id join notif on notif.eleve_id=eleve.id join modalite on modalite.id=notif.modalite_id WHERE etab.id = $id   


-- Carte 
SELECT 
    'map' as component,
    16 as zoom,
    Lat as latitude,
    Lon as longitude,
    250 as height
    FROM etab where etab.id=$id; 
SELECT
    type || ' ' || nom_etab as title,
    Lat AS latitude, 
    Lon AS longitude
FROM etab where etab.id=$id;      

