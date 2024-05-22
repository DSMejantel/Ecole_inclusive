SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Enregistrer le dispositif dans la base
 INSERT INTO dispositif(dispo, coordo) 
 SELECT $dispo as dispo,
 coalesce($coordo,0) as coordo
 WHERE $dispo IS NOT NULL;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;
    

-- Sous Menu Ajout/suppression dispositif
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
/*select 
    'Ajouter' as title,
    'dispositif_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id<3 as disabled,
    'green' as outline;
    */
select 
    'Supprimer' as title,
    'dispositif_delete.sql' as link,
    'trash' as icon,
        $group_id<3 as disabled,
    'red' as outline;

-- Liste et ajout
select 
    'card' as component,
     2      as columns;
select 
    '/dispositif/liste.sql?_sqlpage_embed' as embed;
select 
    '/dispositif/form.sql?_sqlpage_embed' as embed;

 
