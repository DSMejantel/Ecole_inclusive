SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<3;

-- Enregistrer la notification dans la base
 INSERT INTO dispositif(dispo, coordo) 
 SELECT :dispo as dispo,
 coalesce(:coordo,0) as coordo
 WHERE :dispo IS NOT NULL;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;

-- Sous Menu Ajout/suppression dispositif
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Ajouter' as title,
    'dispositif_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id<3 as disabled,
    'green' as outline;
    
select 
    'Supprimer' as title,
    'dispositif_delete.sql' as link,
    'trash' as icon,
        $group_id<3 as disabled,
    'red' as outline;

-- Liste des dispositifs
SELECT 'table' as component,
  'Liste des dispositifs' AS title,
  'icone' as icon,
  'Coordonnateur' as markdown,
  'Accompagnement' as markdown;
SELECT 
  'lifebuoy' as icone,
  dispo AS Dispositif,
  CASE WHEN coordo=1 and $group_id>2
    THEN '[
    ![](./icons/select.svg)
](/dispositif/indisponible.sql?id='||dispositif.id||')' 
WHEN coordo=0 and $group_id>2
    THEN '[
    ![](./icons/square.svg)
](/dispositif/disponible.sql?id='||dispositif.id||')' 
WHEN coordo=1 and $group_id<3
    THEN '[
    ![](./icons/select.svg)
]()'
ELSE '[
    ![](./icons/square.svg)
]()'
END as Coordonnateur,
  CASE WHEN accomp=1 and $group_id>2
    THEN '[
    ![](./icons/select.svg)
](/dispositif/accomp_moins.sql?id='||dispositif.id||')' 
WHEN coalesce(accomp,0)=0 and $group_id>2
    THEN '[
    ![](./icons/square.svg)
](/dispositif/accomp_plus.sql?id='||dispositif.id||')' 
WHEN accomp=1 and $group_id<3
    THEN '[
    ![](./icons/select.svg)
]()'
ELSE '[
    ![](./icons/square.svg)
]()'
END as Accompagnement
FROM dispositif order by dispo;

 
