SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

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
    'certificate-2' as icon,
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
    

-- Sous Menu Ajout/suppression modalité
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Ajouter' as title,
    'modalite_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id::int<2 as disabled,
    'green' as outline;
select 
    'Supprimer' as title,
    'modalite_delete.sql' as link,
    'trash' as icon,
        $group_id::int<2 as disabled,
    'red' as outline;

select 
    'list'             as component,
    'Liste des notifications proposées par la MDPH' as title;
select 
    'Wikipedia'             as title,
    'https://wikipedia.org' as link,
    'An encyclopedia'       as description,
    'blue'                  as color,
    'world'                 as icon,
    '?edit=wikipedia'       as edit_link,
    '?delete=wikipedia'     as delete_link;


 SELECT 'card' as component,
  'Type de notifications' AS title,
   'Liste des notifications proposées par la MDPH' AS description,
  5 as columns;
SELECT 
  type AS title,
  'certificate' as icon
FROM modalite order by type;    
