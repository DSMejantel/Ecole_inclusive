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
            
select 'dynamic' as component, sqlpage.run_sql('etab_menu.sql') as properties;
/*
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
    'teal' as color;
select 
    'Photos' as title,
    'etab_trombi.sql?id=' || $id as link,
    'camera' as icon,
    'teal' as outline;
*/
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

-- Graphique Dispositifs sur établissement
select 
    'chart'               as component,
    'Nombre de dispositifs sur l''établissement' as title,
    'bar'             as type,
        400 as height,
    TRUE as labels,
    1 as toolbar,
    1 as stacked,
    'orange' as color,
    'Nombre de dispositifs' as ytitle;
select 
    dispo as x,
    coalesce(count(affectation.dispositif_id),0) as value
    FROM eleve LEFT JOIN affectation on affectation.eleve_id=eleve.id JOIN dispositif on dispositif.id=affectation.dispositif_id JOIN etab on eleve.etab_id = etab.id WHERE eleve.etab_id=$id GROUP BY dispo ORDER BY eleve.classe ASC;

      
-- Graphique élèves suivis par Classe
select 
    'chart'               as component,
    'Nombre d''élèves suivis par classe' as title,
    'bar'             as type,
            400 as height,
    TRUE as labels,
    1 as toolbar,
    'azure' as color,
    'Classes' as xtitle,
    'Élèves' as ytitle;
select 
    eleve.classe as label,
    eleve.classe as x,
    count(DISTINCT eleve.id) as y
    FROM eleve JOIN etab on eleve.etab_id = etab.id WHERE eleve.etab_id=$id GROUP BY eleve.classe ORDER BY eleve.classe ASC;
select 
    'moyenne' as label,
    'moyenne' as x,
    count(DISTINCT eleve.id)*100/count(distinct eleve.classe)/100 as y
    FROM eleve JOIN etab on eleve.etab_id = etab.id WHERE eleve.etab_id=$id;

   
-- Graphique Dispositifs en place par Classe
select 
    'chart'               as component,
    'Nombre de dispositifs par classe' as title,
    'bar'             as type,
        400 as height,
    TRUE as labels,
    1 as toolbar,
    1 as stacked,
    'pink' as color,
    'Classes' as xtitle,
    'Nombre de dispositifs' as ytitle;
select 
    eleve.classe as x,
    coalesce(count(affectation.dispositif_id),0) as value
    FROM eleve LEFT JOIN affectation on affectation.eleve_id=eleve.id JOIN dispositif on dispositif.id=affectation.dispositif_id JOIN etab on eleve.etab_id = etab.id WHERE eleve.etab_id=$id GROUP BY eleve.classe ORDER BY eleve.classe ASC;

-- Bouton vers détails par classe
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'Détails par classe' as title,
    'etab_stats_classes.sql?id=' || $id as link,
    'chart-histogram' as icon,
    'orange' as color;


