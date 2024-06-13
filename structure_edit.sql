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
    

-- Liste et édition/suppression
 SELECT 'list' as component,
  'Classes' AS title,
  'Liste des classes par établissement' AS description;
SELECT 
  classe as title,
  coalesce(type,'-') || ' ' || coalesce(nom_etab,'-') ||' ('|| coalesce(etab_UAI,'-') ||') ' AS description,
  'trash' as icon,
  'structure_delete.sql?id=' || structure.id  AS link
FROM structure left join etab on structure.etab_UAI=etab.UAI order by etab_UAI,classe; 

