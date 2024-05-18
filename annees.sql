SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Insertion dans la base
 INSERT INTO annee(annee) 
 SELECT $an WHERE $an IS NOT NULL;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
--Sous-menu
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'Enseignant-Référent' as title,
    'referent.sql' as link,
    'writing' as icon,
    'Orange' as color,
    'orange' as outline;
select 
    'type de Notification' as title,
    'modalite.sql' as link,
    'certificate-2' as icon,
    'orange' as color,
    'orange' as outline;
select 
    'Aménagement d''examen' as title,
    'examen.sql' as link,
    'school' as icon,
    'orange' as outline;
select 
    'Dispositifs' as title,
    'dispositif.sql' as link,
    'lifebuoy' as icon,
    'Orange' as color,
    'orange' as outline;
select 
    'Établissements' as title,
    'etab.sql' as link,
    'building-community' as icon,
    'orange' as outline;
select 
    'Niveaux' as title,
    'niveaux.sql' as link,
    'stairs' as icon,
    'orange' as outline;    
select 
    'Années' as title,
    'calendar-month' as icon,
    'orange' as color;     

-- Liste et ajout
select 
    'card' as component,
     2      as columns;
select 
    '/annee/liste.sql?_sqlpage_embed' as embed;
select 
    '/annee/form.sql?_sqlpage_embed' as embed;
    
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'start' as justify; 
select 
    'Générer l''historique de l''année' as title,
    'tool_MAJ_parcours.sql' as link,
    'calendar-month' as icon,
    $group_id::int<4 as disabled,
    'orange' as outline;
