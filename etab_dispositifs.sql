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


-- Sous-menu / bascule
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
    'lifebuoy' as icon,    
    'orange' as color;
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
    
-- Sous-menu / dispositifs
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'lifebuoy' as icon,
    'red' as outline,
    CASE WHEN $dispo_select is Null THEN 'sélectionner un dispositif'
    ELSE 'Dispositif : ' || dispositif.dispo  
    END as title
    From dispositif where dispositif.id=$dispo_select;

select 
    dispositif.dispo ||' ('||count(distinct affectation.eleve_id) ||')' as title,
    'etab_dispositifs.sql?id=' || etab.id || '&dispo_select=' || affectation.dispositif_id as link,
    'lifebuoy' as icon,
    'green' as outline
    FROM etab INNER JOIN eleve on eleve.etab_id=etab.id JOIN affectation on eleve.id=affectation.eleve_id JOIN dispositif on dispositif.id=affectation.dispositif_id where etab.id=$id GROUP BY dispositif.dispo ORDER BY dispositif.dispo ASC;


-- Personnalisation NB_eleve pour version dispositif :
SET NB_accomp = (SELECT count(distinct affectation.eleve_id) FROM affectation JOIN eleve on affectation.eleve_id=eleve.id JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE  eleve.etab_id=$id and affectation.dispositif_id=$dispo_select);


SELECT 'text' AS component, 'Classe :  ' || $classe_selec AS contents;
-- écrire les infos de l'établissement dans le titre de la page [GRILLE]
SELECT 
    'datagrid' as component,
    type || ' ' || nom_etab as title FROM etab WHERE id = $id;
SELECT 
    ' Dispositif : ' as title,
    dispositif.dispo as description,
    'lifebuoy' as icon
    From dispositif where dispositif.id=$dispo_select;
SELECT 
    ' Nombre d''élèves : ' as title,
    $NB_accomp as description,
    'users-group' as icon;

  
-- Liste des élèves
SELECT 'table' as component,
    'Actions' as markdown,
    'Admin' as markdown,
    'nom' as Nom,
    'prenom' as Prénom,
    'dispositif.dispo' as Dispositif,    
    'aesh.aesh_name' as AESH,
    'modalite' as Suivi,
    'objectifs' as Aménagements,
    1 as sort,
    1 as search;
    SELECT 
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    eleve.classe as Classe,
   CASE
       WHEN EXISTS (SELECT eleve.id FROM affectation 
    WHERE eleve.id = affectation.eleve_id) THEN 'black'
        ELSE 'red'
    END AS _sqlpage_color,
      CASE WHEN suivi.aesh_id<>1 and $group_id>1 THEN  '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||suivi.aesh_id||'&tab=Profils) [
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)' 
WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id = amenag.eleve_id)
THEN
'[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||')' 
ELSE
'[
    ![](./icons/alert-triangle-filled.svg)
](notification.sql?id='||eleve.id||')' 
END as Actions,
CASE WHEN $group_id::int>2 THEN
'[
    ![](./icons/pencil.svg)
](eleve_edit.sql?id='||eleve.id||')'
ELSE
'[
    ![](./icons/pencil-off.svg)
]()'
END
as Admin
  FROM eleve LEFT JOIN etab on eleve.etab_id = etab.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id and affectation.dispositif_id=$dispo_select GROUP BY eleve.id ORDER BY eleve.nom ASC;  
-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter les suivis du dispositif '|| dispositif.dispo as title,
    'Suivis'||$dispo_select as filename,
    'file-download' as icon,
    'green' as color
    From dispositif where dispositif.id=$dispo_select;
SELECT 
    eleve.classe as Classe,
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    group_concat(DISTINCT SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '||aesh.aesh_name) as AESH,
    notification.modalite AS Suivi,
    suivi.temps as Temps,
        amenag.info AS Infos,
        amenag.amenagements as Aménagements,
        amenag.objectifs as Objectifs
   FROM eleve LEFT JOIN etab on eleve.etab_id = etab.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN amenag on amenag.eleve_id=eleve.id  LEFT JOIN notification on notification.eleve_id=eleve.id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id WHERE eleve.etab_id=$id and affectation.dispositif_id=$dispo_select GROUP BY eleve.id ORDER BY eleve.nom ASC;  

    
-- fiche détaillée des élèves suivis
SELECT 'title' as component,
   'Fiches des élèves suivis' as contents,
   4 as level;

  SELECT 'table' as component,   
    'comm_suivi' as commentaires,
    'amenagements' as Aménagements,
    'objectifs' as Objectifs;
    SELECT 
    eleve.nom||' '||eleve.prenom as élève,
    eleve.classe as Classe,
    info AS commentaires,
    amenagements AS Aménagements,
    objectifs AS Objectifs
 FROM eleve LEFT JOIN etab on eleve.etab_id = etab.id LEFT JOIN amenag on amenag.eleve_id=eleve.id JOIN affectation on eleve.id=affectation.eleve_id JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.etab_id=$id and affectation.dispositif_id=$dispo_select GROUP BY amenag.id ORDER BY eleve.nom ASC;   
