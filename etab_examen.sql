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
    'etab_notif.sql?id=' || $id as link,
    'certificate' as icon,
    'orange' as outline;
select 
    'Examens' as title,
    'school' as icon,
    'orange' as color;
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
SET NB_eleve = (SELECT count(distinct eleve.id) FROM examen_eleve INNER JOIN eleve on eleve.id=examen_eleve.eleve_id where eleve.etab_id=$id);
SET NB_mesure = (SELECT count(distinct examen_eleve.code_id) FROM examen_eleve JOIN eleve on examen_eleve.eleve_id=eleve.id WHERE eleve.etab_id=$id);
SET NB_aesh = (SELECT count(distinct suivi.aesh_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id JOIN examen_eleve on eleve.id=examen_eleve.eleve_id WHERE eleve.etab_id=$id and suivi.aesh_id<>1);

-- écrire les infos de l'établissement dans le titre de la page [GRILLE]
SELECT 
    'datagrid' as component,
    type || ' ' || nom_etab as title FROM etab WHERE id = $id;
SELECT 
    ' Nombre des différentess mesures : ' as title,
    $NB_mesure as description,
    TRUE           as active,
    'school' as icon;
SELECT 
    ' Élèves avec aménagements d''examen : ' as title,
    $NB_eleve as description,
    'school' as icon;
SELECT 
' élève(s) suivi(s) par AESH ' as title,
    $NB_aesh as description,
    'user-plus' as icon;

-- Liste des aménagements d'examens
select 
    'divider' as component,
    'Aménagements d''examen' as contents,
    'orange' as color;
        
--Onglets
SET tab=coalesce($tab,'Élèves');
select 'tab' as component;

select  'Élèves' as title, 'list-check' as icon, 1 as active, 'etab_examen.sql?id='||$id||'&tab=Élèves' as link, CASE WHEN $tab='Élèves' THEN 'orange' ELSE 'green' END as color;    
select  'Aménagements' as title, 'printer' as icon, 1 as active,'etab_examen.sql?id='||$id||'&tab=Aménagements' as link, CASE WHEN $tab='Aménagements' THEN 'orange' ELSE 'green' END as color; 



SELECT 'table' as component,
    TRUE    as hover,
    TRUE    as small,
    'Actions' as markdown,
    'aucune notification à cette date' as empty_description,
    1 as sort,
    1 as search
    where $tab='Élèves';
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      eleve.classe as Classe,
  group_concat(' '||examen.mesure) as Aménagements,
'[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)
[
    ![](./icons/school.svg)
](notification.sql?id='||eleve.id||'&tab=Examen)' 
 as Actions 
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id JOIN examen_eleve on examen_eleve.eleve_id=eleve.id LEFT JOIN examen on examen.id=examen_eleve.code_id WHERE eleve.etab_id = $id and $tab='Élèves' GROUP BY eleve.id ORDER BY eleve.nom ASC;  

-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter' as title,
    'amenagements_examen' as filename,
    'file-download' as icon,
    'green' as color
        where $tab='Élèves';
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      eleve.classe as Classe,
  group_concat(examen.mesure) as Aménagements,
'[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)' 
 as Actions 
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id JOIN examen_eleve on examen_eleve.eleve_id=eleve.id LEFT JOIN examen on examen.id=examen_eleve.code_id WHERE eleve.etab_id = $id and $tab='Élèves' GROUP BY eleve.id ORDER BY eleve.nom ASC;   

-- Liste des aménagements d'examens
SELECT 'table' as component,
    TRUE    as hover,
    TRUE    as small,
    'Actions' as markdown,
    1 as sort,
    1 as search
            where $tab='Aménagements';
SELECT 
      examen.code as Code,
      examen.mesure as Aménagements,
      count (distinct eleve.id) as Nombre,
      group_concat(' '||eleve.nom||' '||eleve.prenom) as Élèves
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id JOIN examen_eleve on examen_eleve.eleve_id=eleve.id LEFT JOIN examen on examen.id=examen_eleve.code_id WHERE eleve.etab_id = $id  and $tab='Aménagements'GROUP BY examen.mesure ORDER BY examen.code ASC;  
    
-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter' as title,
    'amenagements_examen' as filename,
    'file-download' as icon,
    'green' as color
        where $tab='Aménagements';
SELECT 
      examen.code as Code,
      examen.mesure as Aménagements,
      count (distinct eleve.id) as Nombre,
      group_concat(' '||eleve.nom||' '||eleve.prenom) as Élèves
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id JOIN examen_eleve on examen_eleve.eleve_id=eleve.id LEFT JOIN examen on examen.id=examen_eleve.code_id WHERE eleve.etab_id = $id  and $tab='Aménagements'GROUP BY examen.mesure ORDER BY examen.code ASC;    

