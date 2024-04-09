SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

    -- Enregistrer la notification dans la base
 INSERT INTO modalite(type) SELECT $type WHERE $type IS NOT NULL;

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
    'orange' as color;
select 
    'Établissements' as title,
    'etab.sql' as link,
    'building-community' as icon,
    'orange' as outline;
    
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'end' as justify;
select 
    'Supprimer' as title,
    'modalite_delete.sql' as link,
    'trash' as icon,
    'red' as outline;


-- Liste et ajout
select 
    'card' as component,
     2      as columns;
select 
    '/modalite/liste.sql?_sqlpage_embed' as embed;
select 
    '/modalite/form.sql?_sqlpage_embed' as embed;
 

