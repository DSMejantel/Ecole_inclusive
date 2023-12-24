SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

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
    'certificate' as icon,
    'orange' as color;
select 
    'Suivis' as title,
    'etab_suivi.sql?id=' || $id  ||'&tab=Acc' as link,
    'list-check' as icon,
    'orange' as outline;
select 
    'AESH' as title,
    'etab_aesh.sql?id=' || $id as link,
    'user-plus' as icon,
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
select 
    'button' as component,
    'lg'     as size,
    'center' as justify,
    'pill'   as shape;
select 
    'Liste des Notifications' as title,
    'certificate' as icon,
    'warning' as outline;

SELECT 'table' as component,
    'icon' as Origine,
    'nom' as Nom,
    'prenom' as Prénom,
    'datefin' as Fin,
    'nom_ens_ref' as Référent,
    'Actions' as markdown,
    1 as sort,
    1 as search;
SELECT 
  CASE
       WHEN notification.datefin < datetime(date('now', '+1 day')) THEN 'red'
       WHEN notification.datefin < datetime(date('now', '+350 day')) THEN 'orange'
        ELSE 'green'
    END AS _sqlpage_color,
      eleve.nom as Nom,
      eleve.prenom as Prénom,
  group_concat(DISTINCT modalite.type) as Droits,
  SUBSTR(referent.prenom_ens_ref, 1, 1) ||'. '||nom_ens_ref as Référent,
    strftime('%d/%m/%Y',datefin) AS Fin, 
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
FROM etab INNER JOIN eleve on eleve.etab_id=etab.id JOIN notification on notification.eleve_id = eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id LEFT JOIN affectation on eleve.id=affectation.eleve_id JOIN referent on eleve.referent_id=referent.id WHERE etab.id = $id
GROUP BY notif.eleve_id ORDER BY eleve.nom ASC;  

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
    'PIAL Mende' as title,
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

