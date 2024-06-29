SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<3;

--Insertion dans la base
 INSERT INTO examen(code, mesure) 
    SELECT :code, :mesure WHERE :code IS NOT NULL;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;

-- Liste et ajout
select 
    'card' as component,
     2      as columns;
select 
    '/examen/liste.sql?_sqlpage_embed' as embed;
select 
    '/examen/form.sql?_sqlpage_embed' as embed;
