SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Insertion dans la base
 INSERT INTO examen(code, mesure) 
    SELECT $code, $mesure WHERE $code IS NOT NULL;

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
    'school' as icon,
    'orange' as color;
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
    'Orange' as color,
    'orange' as outline;    

-- Liste et ajout
select 
    'card' as component,
     2      as columns;
select 
    '/examen/liste.sql?_sqlpage_embed' as embed;
select 
    '/examen/form.sql?_sqlpage_embed' as embed;
