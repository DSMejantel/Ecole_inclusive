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

-- En-tête
select 'dynamic' as component, sqlpage.run_sql('etab_menu.sql') as properties;
/*
-- basculer vers notifications / Aesh
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
    'list-check' as icon,
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
*/
-- Set a variable 
SET NB_eleve = (SELECT count(distinct eleve.id) FROM eleve where eleve.etab_id=$id);
SET NB_accomp = (SELECT count(distinct suivi.eleve_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id);
SET NB_notif = (SELECT count(notification.id) FROM notification JOIN eleve on notification.eleve_id = eleve.id WHERE eleve.etab_id = $id);
SET NB_aesh = (SELECT count(distinct suivi.aesh_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id);

-- create a temporary table to preprocess the data
create temporary table if not exists AESH_suivi(aesh_id,temps_calcul);
delete  from AESH_suivi; 
insert into AESH_suivi(aesh_id,temps_calcul)
SELECT aesh.id, (sum((suivi.temps)*2/mut)/2+sum(distinct(aesh.tps_ULIS))+sum(distinct(aesh.tps_mission))+sum(distinct(aesh.tps_synthese))) FROM suivi LEFT JOIN aesh on suivi.aesh_id=aesh.id JOIN eleve on suivi.eleve_id=eleve.id GROUP BY aesh.id;

--select 'table' as component;
--select * from AESH_suivi;

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
SET tab=coalesce($tab,'Tous');
select 'tab' as component,
1 as center;
select  'Tous'  as title, 'users-group' as icon, 1  as active, 'etab_suivi.sql?id='||$id||'&tab=Tous' as link, CASE WHEN $tab='Tous' THEN 'orange' ELSE 'green' END as color;
select  'Élèves avec Accompagnement'  as title, 'user-plus' as icon, 1  as active, 'etab_suivi.sql?id='||$id||'&tab=Acc' as link, CASE WHEN $tab='Acc' THEN 'orange' ELSE 'green' END as color;
select  'Élèves sans Accompagnement' as title, 'user-off' as icon, 0 as active, 'etab_suivi.sql?id='||$id||'&tab=SansAcc' as link, CASE WHEN $tab='SansAcc' THEN 'orange' ELSE 'green' END as color;
select  'Élèves en attente' as title, 'alert-triangle-filled' as icon, 1 as active, 'etab_suivi.sql?id='||$id||'&tab=Att' as link, CASE WHEN $tab='Att' THEN 'orange' ELSE 'green' END as color;
select  'Derniers changements' as title, 'clock' as icon, 1 as active, 'etab_suivi.sql?id='||$id||'&tab=Last' as link, CASE WHEN $tab='Last' THEN 'orange' ELSE 'green' END as color;


select 
    'divider' as component,
    'Tous les élèves de l''établissement' as contents,
    'orange' as color
        WHERE $tab='Tous';
        
SELECT 'table' as component,   
    'Actions' as markdown,
    1 as sort,
    1 as search
        WHERE $tab='Tous';
 SELECT 
    eleve.nom ||' '||eleve.prenom as Élève,
    eleve.classe AS Classe,
    eleve.niveau AS Niveau,
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
FROM eleve INNER JOIN etab on eleve.etab_id = etab.id LEFT JOIN notification on notification.eleve_id=eleve.id LEFT JOIN affectation on eleve.id=affectation.eleve_id JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.etab_id=$id AND $tab='Tous' GROUP BY eleve.id ORDER BY eleve.nom; 

-- Liste des suivis avec accompagnement
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
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id LEFT JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id Where eleve.etab_id=$id group by notification.id;


select 
    'divider' as component,
    'Liste des élèves avec accompagnement' as contents,
    'orange' as color
        WHERE $tab='Acc';
    
SELECT 'table' as component,
    'Actions' as markdown,
    'Temps' as markdown,
    'AESH' as markdown,
    'Suivi' as markdown,
    'Expirés' as markdown,
    1 as small,
    1 as sort,
    1 as search
        WHERE $tab='Acc';
    SELECT 
    eleve.id as _sqlpage_id,
    eleve.nom ||' '||eleve.prenom as Élève,
    CASE WHEN $group_id>2 THEN     suivi.temps||' h[
    ![](./icons/circle-minus.svg)
](/suivi/diminuer.sql?suivi='||suivi.id||'&ligne='||eleve.id||'&etab='||$id||' "diminuer")
     [
    ![](./icons/circle-plus.svg)
](/suivi/augmenter.sql?suivi='||suivi.id||'&ligne='||eleve.id||'&etab='||$id||' "augmenter")' 
    ELSE suivi.temps||' h' END as Temps,
    eleve.classe AS Classe,
    eleve.niveau AS Niveau,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,
    group_concat(distinct Etab_notif.droits_ouverts) as Droits,
    CASE
       WHEN group_concat(distinct Etab_notif.droits_fermes) <> '-' THEN   '[
    ![](./icons/first-aid-kit-off.svg)
](/ "Fin de droit pour : '||group_concat(distinct Etab_notif.droits_fermes)||'")' 
    ELSE '' END as Expirés,
    SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '||aesh.aesh_name||' ('||AESH_suivi.temps_calcul||'/'||aesh.quotite||')' as AESH,
       CASE
       WHEN ind=1 THEN 'ind'
       WHEN mut=2 THEN 'mut'
       END  AS Suivi,
    CASE WHEN $group_id>1 THEN          '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil "Dossier de l''élève")[
    ![](./icons/pencil.svg)
](/suivi/suivi_edit.sql?suivi='||suivi.id||'&eleve='||eleve.id||'&etab='||$id||' "Éditer le suivi")[
    ![](./icons/trash.svg)
](/suivi/suivi_delete_confirm.sql?suivi='||suivi.id||'&etab='||$id||' "Supprimer définitivement le suivi")'
    END as Suivi, 
    CASE WHEN $group_id>1 THEN     '[
    ![](./icons/square-rounded-plus.svg "ajouter un suivi")
](/suivi/suivi_ajout.sql?id='||eleve.id||'&etab='||$id||')[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil "Dossier de l''élève")'
    ELSE
    '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil "Dossier de l''élève")'
    END as Actions,
    CASE WHEN $group_id>1 THEN '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||suivi.aesh_id||'&tab=Profils)'
ELSE ''
    END as AESH,
    CASE WHEN AESH_suivi.temps_calcul>aesh.quotite THEN '[
    ![](./icons/alert-triangle-red.svg)
](aesh_suivi.sql?id='||suivi.aesh_id||'&tab=Profils)'
ELSE ''
    END as AESH,
CASE
       WHEN (SELECT max(datefin) FROM notification WHERE notification.eleve_id=eleve.id) < datetime(date('now', '+1 day')) THEN 'red'
       WHEN (SELECT max(datefin) FROM notification WHERE notification.eleve_id=eleve.id) < datetime(date('now', '+350 day')) THEN 'orange'
       ELSE 'green'
    END AS _sqlpage_color
    FROM eleve JOIN etab on eleve.etab_id = etab.id LEFT JOIN Etab_notif on Etab_notif.eleve_id=eleve.id JOIN affectation on eleve.id=affectation.eleve_id JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN AESH_suivi on AESH_suivi.aesh_id=aesh.id LEFT JOIN notification on notification.eleve_id=eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id WHERE eleve.etab_id=$id and dispositif.accomp=1 and $tab='Acc' GROUP BY eleve.id, suivi.id ORDER BY eleve.classe; 

-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter' as title,
    'eleves_suivis_etablissement' as filename,
    'file-download' as icon,
    'green' as color
    WHERE $tab='Acc';
    SELECT 
    eleve.nom ||' '||eleve.prenom as Élève,
    coalesce(suivi.temps,0)||' h' as Temps,
    eleve.classe AS Classe,
    eleve.niveau AS Niveau,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,
    coalesce((group_concat(distinct Etab_notif.droits_ouverts)),0) as Droits,
    coalesce(SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '||aesh.aesh_name||' ('||AESH_suivi.temps_calcul||'/'||aesh.quotite||')',0) as AESH,
       CASE
       WHEN ind=1 THEN 'ind'
       WHEN mut=2 THEN 'mut'
       ELSE '-'
       END  AS Suivi,
    notification.datefin AS Fin 
    FROM eleve JOIN etab on eleve.etab_id = etab.id LEFT JOIN Etab_notif on Etab_notif.eleve_id=eleve.id JOIN affectation on eleve.id=affectation.eleve_id JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN AESH_suivi on AESH_suivi.aesh_id=aesh.id LEFT JOIN notification on notification.eleve_id=eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id WHERE eleve.etab_id=$id and dispositif.accomp=1 and $tab='Acc' GROUP BY eleve.id, suivi.id ORDER BY eleve.classe; 

  -- Liste des suivis sans accompagnement
select 
    'divider' as component,
    'Liste des élèves sans accompagnements' as contents,
    'orange' as color
        WHERE $tab='SansAcc';

    
SELECT 'table' as component,   
    'Actions' as markdown,
    1 as sort,
    1 as search
        WHERE $tab='SansAcc';
 SELECT 
    eleve.nom ||' '||eleve.prenom as Élève,
    eleve.classe AS Classe,
    eleve.niveau AS Niveau,
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
    'divider' as component,
    'Liste des élèves en attente' as contents,
    'orange' as color
        WHERE $tab='Att';

   
SELECT 'table' as component,   
    'Actions' as markdown,
    1 as sort,
    1 as search
            WHERE $tab='Att';
 SELECT 
    eleve.nom ||' '||eleve.prenom as Élève,
    eleve.classe AS Classe,
    eleve.niveau AS Niveau,
         '[
    ![](./icons/alert-triangle-filled.svg)
](notification.sql?id='||eleve.id||'  "Dossier de l''élève")' as Actions
FROM suivi RIGHT JOIN eleve on suivi.eleve_id=eleve.id JOIN etab on eleve.etab_id = etab.id  WHERE not EXISTS (SELECT eleve.id FROM affectation WHERE eleve.id = affectation.eleve_id) and etab.id = $id and $tab='Att' GROUP BY eleve.id ORDER BY eleve.nom; 

-- Liste des derniers changements
select 
    'divider' as component,
    'Liste des derniers changements' as contents,
    'orange' as color
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

