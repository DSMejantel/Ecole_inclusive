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
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;

select 'spreadsheet' as component,
  'tableau_01_update.sql' as update_link,
  'Liste des suivis' as sheet_name,
  100 as column_width,
  50 as row_height,
  1 as freeze_y,
  false as show_grid;

select 
  row_number() over (order by eleve_id) as x,
  aesh_id as y,
  temps as value,
  id
from suivi
order by eleve_id;




