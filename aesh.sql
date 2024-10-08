SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'etablissement.sql?restriction' AS link
        WHERE $group_id<'2';

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
            $group_id<3 as disabled,
    'green' as outline;
    
SELECT 'table' as component,
    TRUE    as hover,
    'Actions' as markdown,
        'Admin' as markdown,
    1 as sort,
    1 as search;
SELECT 
  aesh_name AS Nom,
  aesh_firstname AS Prénom,
  etab.nom_etab AS Établissement,
  CASE WHEN $group_id>2 
    THEN    tel_aesh 
    ELSE 'numéro masqué'
    END as Téléphone,
  courriel_aesh as courriel,
  quotite as Quotité,
      '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils)' as Actions,
CASE WHEN $group_id=3 THEN
      '[
    ![](./icons/pencil.svg)
](aesh_edit.sql?id='||aesh.id||')[
    ![](./icons/trash-off.svg)
]()' 
WHEN $group_id=4 THEN
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
FROM aesh join user_info on aesh.username=user_info.username join etab on etab.id=user_info.etab ORDER BY aesh_name ASC;   
