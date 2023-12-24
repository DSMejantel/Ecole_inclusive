SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'2';

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
    'Dispositifs' as title,
    'dispositif.sql' as link,
    'lifebuoy' as icon,
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
    'dispositif_delete.sql' as link,
    'trash' as icon,
    'red' as outline;


--- Saisir un dispositif 
SELECT 
    'form' as component,
    'Nouveau dispostif' as title,
    'enregistrer' as validate;
    
    SELECT 'Dispositif' AS label, 'dispo' AS name;
    
-- Enregistrer la notification dans la base
 INSERT INTO dispositif(dispo) SELECT $dispo WHERE $dispo IS NOT NULL;
 
 SELECT 'card' as component,
  'Liste des dispositifs' AS title,
   'Liste des dispositifs sur les établissements concernés' AS description,
  5 as columns;
SELECT 
  dispo AS title,
  'lifebuoy' as icon
FROM dispositif order by dispo;  
