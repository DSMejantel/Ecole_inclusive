SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Enregistrer la notification dans la base
 INSERT INTO dispositif(dispo, coordo) 
 SELECT $dispo as dispo,
 coalesce($coordo,0) as coordo
 WHERE $dispo IS NOT NULL;

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
    'modalite.sql' as link,
    'certificate-2' as icon,
    'orange' as outline;
select 
    'Aménagement d''examen' as title,
    'examen.sql' as link,
    'school' as icon,
    'orange' as outline;
select 
    'Dispositifs' as title,
    'lifebuoy' as icon,
    'orange' as color;
select 
    'Établissements' as title,
    'etab.sql' as link,
    'building-community' as icon,
    'orange' as outline;
select 
    'Niveaux' as title,
    'niveaux.sql' as link,
    'stairs' as icon,
    'Orange' as color,
    'orange' as outline;    

-- Sous Menu Ajout/suppression dispositif
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Ajouter' as title,
    'dispositif_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id::int<3 as disabled,
    'green' as outline;
    
select 
    'Supprimer' as title,
    'dispositif_delete.sql' as link,
    'trash' as icon,
        $group_id::int<3 as disabled,
    'red' as outline;

-- Liste des dispositifs
SELECT 'table' as component,
  'Liste des dispositifs' AS title,
  'icone' as icon,
  'Coordonnateur' as markdown;
SELECT 
  'lifebuoy' as icone,
  dispo AS Dispositif,
  CASE WHEN coordo::int=1 and $group_id>2
    THEN '[
    ![](./icons/select.svg)
](/dispositif/indisponible.sql?id='||dispositif.id||')' 
WHEN coordo::int=0 and $group_id>2
    THEN '[
    ![](./icons/square.svg)
](/dispositif/disponible.sql?id='||dispositif.id||')' 
WHEN coordo::int=1 and $group_id<3
    THEN '[
    ![](./icons/select.svg)
]()'
ELSE '[
    ![](./icons/square.svg)
]()'
END as Coordonnateur
FROM dispositif order by dispo;

 
