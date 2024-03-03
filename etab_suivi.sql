SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties; 

-- basculer vers notifications / Aesh
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
    'list-check' as icon,
    'orange' as color;
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
    TRUE           as active,
    'briefcase' as icon;
SELECT 
' AESH ' as title,
    $NB_aesh as description,
    'user-plus' as icon;
--Onglets
SET tab=coalesce($tab,'Acc');
select 'tab' as component,
1 as center;
select  'Élèves avec Accompagnement'  as title, 'user-plus' as icon, 1  as active, 'etab_suivi.sql?id='||$id||'&tab=Acc' as link, CASE WHEN $tab='Acc' THEN 'orange' ELSE 'green' END as color;
select  'Élèves sans Accompagnement' as title, 'user-off' as icon, 0 as active, 'etab_suivi.sql?id='||$id||'&tab=SansAcc' as link, CASE WHEN $tab='SansAcc' THEN 'orange' ELSE 'green' END as color;
select  'Élèves en attente' as title, 'alert-triangle-filled' as icon, 1 as active, 'etab_suivi.sql?id='||$id||'&tab=Att' as link, CASE WHEN $tab='Att' THEN 'orange' ELSE 'green' END as color;
select  'Derniers changements' as title, 'clock' as icon, 1 as active, 'etab_suivi.sql?id='||$id||'&tab=Last' as link, CASE WHEN $tab='Last' THEN 'orange' ELSE 'green' END as color;

-- Liste des suivis avec accompagnement
select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape
        WHERE $tab='Acc';
select 
    'Liste des élèves avec accompagnement' as title,
    'user-plus' as icon,
    'orange' as outline
    WHERE $tab='Acc';
    
SELECT 'table' as component,   
    'Actions' as markdown,
    1 as sort,
    1 as search
        WHERE $tab='Acc';
    SELECT 
    SUBSTR(eleve.prenom, 1, 1) ||'. '||eleve.nom as Élève,
    suivi.temps as Temps,
    eleve.classe AS Classe,
           CASE
       WHEN ind=1 THEN 'ind'
       WHEN mut=2 THEN 'mut'
       END  AS Suivi,
      group_concat(DISTINCT modalite.type) as Droits,
    group_concat(DISTINCT SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '||aesh.aesh_name) as AESH,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,
         '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||suivi.aesh_id||'&tab=Profils)' as Actions
FROM eleve INNER JOIN etab on eleve.etab_id = etab.id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN notification on notification.eleve_id=eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id LEFT JOIN affectation on suivi.eleve_id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.etab_id=$id and suivi.aesh_id<>1 and $tab='Acc' GROUP BY suivi.id ORDER BY eleve.nom;
 
-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter' as title,
    'eleves_suivis_etablissement' as filename,
    'file-download' as icon,
    'green' as color
    WHERE $tab='Acc';
SELECT 
     eleve.nom as Nom,
      eleve.prenom as Prénom,
       suivi.temps as Temps,
                 CASE
       WHEN ind=1 THEN 'ind'
       WHEN mut=2 THEN 'mut'
       END  AS Suivi,
      group_concat(DISTINCT modalite.type) as Droits,
  etab.nom_etab as Établissement,
    group_concat(dispositif.dispo) as Dispositifs,
  datefin AS Fin  
FROM eleve INNER JOIN etab on eleve.etab_id = etab.id JOIN suivi on suivi.eleve_id=eleve.id JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN notification on notification.eleve_id=eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id LEFT JOIN affectation on suivi.eleve_id=affectation.eleve_id JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.etab_id=$id and suivi.aesh_id<>1 and $tab='Acc' GROUP BY suivi.id ORDER BY eleve.nom; 
  
  -- Liste des suivis sans accompagnement

select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape
        WHERE $tab='SansAcc';
select 
    'Liste des élèves sans accompagnements' as title,
    'user-off' as icon,
    'orange' as outline
        WHERE $tab='SansAcc';
    
SELECT 'table' as component,   
    'Actions' as markdown,
    1 as sort,
    1 as search
        WHERE $tab='SansAcc';
 SELECT 
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    eleve.classe AS Classe,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,    
CASE WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id = amenag.eleve_id)
THEN
'[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||')' 
ELSE
'[
    ![](./icons/alert-triangle-filled.svg)
](notification.sql?id='||eleve.id||')' 
END as Actions
FROM eleve INNER JOIN etab on eleve.etab_id = etab.id LEFT JOIN notification on notification.eleve_id=eleve.id LEFT JOIN affectation on eleve.id=affectation.eleve_id JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE not EXISTS (SELECT eleve.id FROM suivi WHERE eleve.id = suivi.eleve_id) and eleve.etab_id=$id AND $tab='SansAcc' GROUP BY eleve.id ORDER BY eleve.nom; 

  -- Liste des élèves en attente

select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape
        WHERE $tab='Att';
select 
    'Liste des élèves en attente' as title,
    'alert-triangle-filled' as icon,
    'red' as outline
            WHERE $tab='Att';
   
SELECT 'table' as component,   
    'Actions' as markdown,
    1 as sort,
    1 as search
            WHERE $tab='Att';
 SELECT 
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    eleve.classe AS Classe,
         '[
    ![](./icons/alert-triangle-filled.svg)
](notification.sql?id='||eleve.id||')' as Actions
FROM suivi RIGHT JOIN eleve on suivi.eleve_id=eleve.id JOIN etab on eleve.etab_id = etab.id  WHERE not EXISTS (SELECT eleve.id FROM affectation WHERE eleve.id = affectation.eleve_id) and etab.id = $id and $tab='Att' ORDER BY eleve.nom; 

-- Liste des derniers changements
select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape
        WHERE $tab='Last';
select 
    'Liste des derniers changements' as title,
    'clock' as icon,
    'orange' as outline
    WHERE $tab='Last';
    
SELECT 'table' as component,   
    'Actions' as markdown,
    1 as sort,
    1 as search
        WHERE $tab='Last';
SELECT 
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    strftime('le %d/%m/%Y à %Hh%M:%S', eleve.modification) as Modifié,
    eleve.editeur AS Par
FROM eleve WHERE eleve.etab_id=$id and $tab='Last' ORDER BY eleve.modification DESC LIMIT 10;

