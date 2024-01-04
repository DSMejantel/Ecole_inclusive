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
    'orange' as color;
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
    'briefcase' as icon;
SELECT 
' AESH ' as title,
    $NB_aesh as description,
    TRUE           as active,
    'user-plus' as icon;
  
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
    'etab_stats_classes.sql?id=' || etab.id || '&classe_select=' || eleve.classe as link,
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
-- Différents Dispositifs en place par Classe
select 
    'chart'   as component,
    'Dispositifs en '||$classe_select as title,
    'bar'     as type,
    400 as height,
    10  as xticks,
    TRUE as stacked,
    TRUE       as toolbar,
    TRUE      as labels;
select 
    Nom_dispositif as series,
    Nom_dispositif as x,
    Nombre   as value
    FROM stats01 WHERE etab=$id and classe=$classe_select;

-- Différents Dispositifs en place par Classe
select 
    'chart'   as component,
    'Dispositifs en '||$classe_select as title,
    'pie'     as type,
    400 as height,
    TRUE       as toolbar,
    TRUE      as labels;
select 
    Nom_dispositif as label,
    Nombre   as value
    FROM stats01 WHERE etab=$id and classe=$classe_select;
    
-- Bouton vers statistiques
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'Statistiques Établissement' as title,
    'etab_stats.sql?id=' || $id as link,
    'chart-histogram' as icon,
    'orange' as color;

