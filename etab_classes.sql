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
    'users-group' as icon,    
    'orange' as color;
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


-- Sous-menu / classes
SET classe_etab = (SELECT classe FROM eleve INNER JOIN etab on eleve.etab_id = etab.id where etab.id=$id)
SET classe_select = coalesce($Classe, coalesce($classe_select, $classe_etab));
/*
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
*/ 

/*   
--alternative
 SELECT 
    'form' as component,
    'etab_classes.sql?id=' || $id || '&classe_select=' ||$Classe AS action,
    'Valider' as validate,
    'green'           as validate_color;   
     SELECT 'Classe' AS name, 'select' as type, 3 as width, $classe_select as value, json_group_array(json_object('label', classe, 'value', classe)) as options FROM (select distinct eleve.classe as classe, eleve.classe as value FROM eleve JOIN etab on eleve.etab_id=etab.id WHERE eleve.etab_id=$id  ORDER BY eleve.classe DESC);

-- Calcul des variables établissement
SET NB_eleve = (SELECT count(distinct eleve.id) FROM eleve where eleve.etab_id=$id and eleve.classe=$classe_select);
-- Personnalisation NB_accomp pour version classe :
SET NB_accomp = (SELECT count(distinct suivi.eleve_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE suivi.aesh_id<>1 and eleve.etab_id=$id and eleve.classe=$classe_select);
SET NB_notif = (SELECT count(notification.id) FROM notification JOIN eleve on notification.eleve_id = eleve.id WHERE eleve.etab_id = $id and eleve.classe=$classe_select);
SET NB_aesh = (SELECT count(distinct suivi.aesh_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id and eleve.classe=$classe_select and suivi.aesh_id<>1);

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
*/    
-- En-tête
select 
    'card' as component,
     2      as columns;
select 
    '/classe/choix.sql?_sqlpage_embed'|| '&classe_select=' ||$classe_select||'&id=' || $id  as embed;
select 
    '/classe/tableau.sql?_sqlpage_embed'|| '&classe_select=' ||$classe_select||'&id=' || $id as embed;
  
--Onglets
SET tab=coalesce($tab,'Résumé');
select 'tab' as component;

select  'Résumé' as title, 'list-check' as icon, 1 as active, 'etab_classes.sql?id='||$id||'&classe_select='|| $classe_select||'&tab=Résumé' as link, CASE WHEN $tab='Résumé' THEN 'orange' ELSE 'green' END as color;    
select  'Détails' as title, 'printer' as icon, 1 as active,'etab_classes.sql?id='||$id||'&classe_select='|| $classe_select||'&tab=Détails' as link, CASE WHEN $tab='Détails' THEN 'orange' ELSE 'green' END as color; 

-- Liste des élèves
SELECT 'table' as component,
    TRUE    as hover,
    TRUE    as small,
    'Actions' as markdown,
    'Admin' as markdown,
    1 as sort,
    1 as search
    where $tab='Résumé';
    
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
      CASE WHEN suivi.aesh_id>1 and $group_id>1 THEN  '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||suivi.aesh_id||'&tab=Profils "Fiche AESH") [
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil "Dossier élève")' 
WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id = amenag.eleve_id)
THEN
'[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||' "Dossier élève")' 
ELSE
'[
    ![](./icons/alert-triangle-filled.svg)
](notification.sql?id='||eleve.id||' "Dossier incomplet pour l''élève")' 
END as Actions,
CASE WHEN EXISTS (SELECT eleve.id FROM examen_eleve WHERE eleve.id = examen_eleve.eleve_id)
THEN
'[
    ![](./icons/school.svg)
](notification.sql?id='||eleve.id||'&tab=Examen "Aménagements d''examen")' 
ELSE ''
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
  FROM eleve INNER JOIN etab on eleve.etab_id = etab.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN notification on notification.eleve_id=eleve.id WHERE eleve.etab_id=$id and eleve.classe=$classe_select and $tab='Résumé' GROUP BY eleve.id ORDER BY eleve.nom ASC;  
  
-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter les suivis de la classe '|| $classe_select as title,
    'Suivis'||$classe_select as filename,
    'file-download' as icon,
    'green' as color
        where $tab='Résumé';
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
  FROM eleve INNER JOIN etab on eleve.etab_id = etab.id LEFT JOIN amenag on amenag.eleve_id=eleve.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN notification on notification.eleve_id=eleve.id WHERE eleve.etab_id=$id and eleve.classe=$classe_select and $tab='Résumé' GROUP BY amenag.id ORDER BY eleve.nom ASC;  

    
-- fiche détaillée des élèves suivis
-- Vers page simplifiée pour impression
select 
    'button' as component,
    'sm'     as size,
    --'pill'   as shape,
    'end' as justify
               where $tab='Détails';
select 
    'Visualiser pour impression' as title,
    'etab_classes_print.sql?id=' || $id ||'&classe_select='|| $classe_select as link,
    'printer' as icon,
    'green' as outline
               where $tab='Détails';

SELECT 'text' as component,
   'Fiches des élèves suivis' as title
           where $tab='Détails';

  SELECT 'table' as component, 
    TRUE    as hover,
    TRUE    as small
    where $tab='Détails';
    
    SELECT 
    eleve.nom||' '||eleve.prenom as élève,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,    
    amenag.info AS commentaires,
    amenag.amenagements AS Aménagements,
    amenag.objectifs AS Objectifs
  FROM eleve LEFT JOIN etab on eleve.etab_id = etab.id LEFT JOIN amenag on amenag.eleve_id=eleve.id LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.etab_id=$id and eleve.classe=$classe_select and $tab='Détails' GROUP BY amenag.id ORDER BY eleve.nom ASC;  
  

