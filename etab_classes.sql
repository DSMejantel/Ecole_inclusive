SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties; 

-- Sous-menu / bascule
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
    'etab_aesh.sql?id=' || $id as link,
    'user-plus' as icon,
    'orange' as outline;
select 
    'Classes' as title,
    'users-group' as icon,    
    'orange' as color;
select 
    'Dispositifs' as title,
    'etab_dispositifs.sql?id=' || $id as link,
    'lifebuoy' as icon,    
    'orange' as outline;
-- Sous-menu / classes
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    CASE WHEN $classe_select is Null THEN 'sélectionner une classe'
    ELSE 'Classe : ' || $classe_select 
    END as title,
    'users-group' as icon,
    'red' as outline;
select 
    eleve.classe as title,
    'etab_classes.sql?id=' || etab.id || '&classe_select=' || eleve.classe as link,
    'users-group' as icon,
    'green' as outline
    FROM etab INNER JOIN eleve on eleve.etab_id=etab.id where etab.id=$id GROUP BY eleve.classe ORDER BY eleve.classe ASC;

-- Set a variable 
SET NB_eleve = (SELECT count(distinct eleve.id) FROM eleve where eleve.etab_id=$id and eleve.classe=$classe_select);
-- Personnalisation NB_accomp pour version classe :
SET NB_accomp = (SELECT count(distinct suivi.eleve_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE suivi.aesh_id<>1 and eleve.etab_id=$id and eleve.classe=$classe_select);
SET NB_notif = (SELECT count(notification.id) FROM notification JOIN eleve on notification.eleve_id = eleve.id WHERE eleve.etab_id = $id and eleve.classe=$classe_select);
SET NB_aesh = (SELECT count(distinct suivi.aesh_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id and eleve.classe=$classe_select and suivi.aesh_id<>1);

SELECT 'text' AS component, 'Classe :  ' || $classe_select AS contents;
-- écrire les infos de l'établissement dans le titre de la page [GRILLE]
SELECT 
    'datagrid' as component,
    type || ' ' || nom_etab ||' --- Classe : ' || $classe_select as title FROM etab WHERE id = $id;
SELECT 
    ' Élèves accompagnés : ' as title,
    $NB_accomp as description,
    'users-plus' as icon;
SELECT 
    ' Élèves à suivre : ' as title,
    $NB_eleve as description,
    TRUE           as active,
    'briefcase' as icon;
SELECT 
' AESH ' as title,
    $NB_aesh as description,
    'user-plus' as icon;

-- Liste des élèves
SELECT 'table' as component,
    TRUE    as hover,
    TRUE    as small,
    'Actions' as markdown,
    'Admin' as markdown,
    1 as sort,
    1 as search;
    SELECT 
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,
    group_concat(DISTINCT SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '||aesh.aesh_name) as AESH,
    --    suivi.objectifs as Objectifs,
   CASE
       WHEN EXISTS (SELECT eleve.id FROM amenag 
    WHERE eleve.id = amenag.eleve_id) THEN 'black'
        ELSE 'red'
    END AS _sqlpage_color,
      CASE WHEN suivi.aesh_id>1 THEN  '[
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
CASE WHEN $group_id::int>1 THEN
'[
    ![](./icons/pencil.svg)
](eleve_edit.sql?id='||eleve.id||')'
ELSE
'[
    ![](./icons/pencil-off.svg)
]()'
END
as Admin
  FROM eleve INNER JOIN etab on eleve.etab_id = etab.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN notification on notification.eleve_id=eleve.id WHERE eleve.etab_id=$id and eleve.classe=$classe_select GROUP BY eleve.id ORDER BY eleve.nom ASC;  

-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter les suivis de la classe '|| $classe_select as title,
    'Suivis'||$classe_select as filename,
    'file-download' as icon,
    'green' as color;
SELECT 
    eleve.classe as Classe,
    eleve.nom as Nom,
    eleve.prenom as Prénom,
     group_concat(DISTINCT dispositif.dispo) as Dispositif,
     group_concat(DISTINCT SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '||aesh.aesh_name) as AESH,
     notification.modalite AS Suivi,
     suivi.temps as Temps,
        amenag.info AS Infos,  
        amenag.amenagements as Aménagements,
        amenag.objectifs as Objectifs
  FROM eleve INNER JOIN etab on eleve.etab_id = etab.id LEFT JOIN amenag on amenag.eleve_id=eleve.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN notification on notification.eleve_id=eleve.id WHERE eleve.etab_id=$id and eleve.classe=$classe_select GROUP BY amenag.id ORDER BY eleve.nom ASC;  

    
-- fiche détaillée des élèves suivis
SELECT 'text' as component,
   'Fiches des élèves suivis' as title;

  SELECT 'table' as component, 
    TRUE    as hover,
    TRUE    as small;
    SELECT 
    eleve.nom||' '||eleve.prenom as élève,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,    
    amenag.info AS commentaires,
    amenag.amenagements AS Aménagements,
    amenag.objectifs AS Objectifs
  FROM eleve LEFT JOIN etab on eleve.etab_id = etab.id LEFT JOIN amenag on amenag.eleve_id=eleve.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.etab_id=$id and eleve.classe=$classe_select GROUP BY amenag.id ORDER BY eleve.nom ASC;  
