SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<3;

--Insertion dans la base
SET etablissement_id = (SELECT id FROM etab WHERE etab.UAI = :etab);
 INSERT INTO structure(etab_UAI, etab_id,classe) 
    SELECT :etab,CAST($etablissement_id as integer), :classe WHERE :classe IS NOT NULL;
--correctif
UPDATE structure SET etab_id=$etablissement_id WHERE etab_UAI=:etab
--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;
    

-- Liste et ajout
select 
    'card' as component,
    1  as columns;
select 
    '/structure/form.sql?_sqlpage_embed' as embed;
select 
    '/structure/liste.sql?_sqlpage_embed' as embed;

select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Supprimer une classe' as title,
    'structure_edit.sql' as link,
    'trash' as icon,
    'red' as outline;  
