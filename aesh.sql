SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Accompagnants' as title,
    'user-plus' as icon,
    'green' as color;
select 
    'Ajouter un Accompagnant' as title,
    'aesh_ajout.sql' as link,
    'square-rounded-plus' as icon,
            $group_id::int<2 as disabled,
    'green' as outline;
    
-- Tableau des AESH

SELECT 'table' as component,
    'Actions' as markdown,
        'Admin' as markdown,
    'aesh_name' as Nom,
    'aesh_firstname' as Prénom,
    'tel_aesh' as Téléphone,
    'quotite' as Quotité,
    'courriel_aesh' as courriel,
    1 as sort,
    1 as search;
SELECT 
  aesh_name AS Nom,
  aesh_firstname AS Prénom,
  tel_aesh as Téléphone,
  courriel_aesh as courriel,
  quotite as Quotité,
      '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils)' as Actions,
CASE WHEN $group_id::int=2 THEN
      '[
    ![](./icons/pencil.svg)
](aesh_edit.sql?id='||aesh.id||')[
    ![](./icons/trash-off.svg)
]()' 
WHEN $group_id::int=3 THEN
      '[
    ![](./icons/pencil.svg)
](aesh_edit.sql?id='||aesh.id||'&username='||aesh.username||')[
    ![](./icons/trash.svg)
](aesh_delete.sql?id='||aesh.id||')' 
ELSE
      '[
    ![](./icons/pencil-off.svg)
]()[
    ![](./icons/trash-off.svg)
]()' 
END as Admin
FROM aesh WHERE id<>1 ORDER BY aesh_name ASC;   

