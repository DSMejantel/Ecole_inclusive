SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<3;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
SET page='Types de notifications';
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;

-- Sous Menu Ajout/suppression modalité
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Ajouter' as title,
    'modalite_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id<3 as disabled,
    'green' as outline;
select 
    'Supprimer' as title,
    'modalite_delete.sql' as link,
    'trash' as icon,
        $group_id<3 as disabled,
    'red' as outline;

-- Liste des notifications possibles
SELECT 'table' as component,
  'Type de notification MDA/MDPH' AS title,
  'icone' as icon;
SELECT 
  'certificate' as icone,
  type AS Modalité
FROM modalite order by type;  
