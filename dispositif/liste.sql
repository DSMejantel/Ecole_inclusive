SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Liste des dispositifs
SELECT 'table' as component,
  'Liste des dispositifs' AS title,
  'icone' as icon,
  'Coordonnateur' as markdown;
SELECT 
  'lifebuoy' as icone,
  dispo AS Dispositif,
  CASE WHEN coordo=1
    THEN '[
    ![](./icons/select.svg)
](/dispositif/indisponible.sql?id='||dispositif.id||')' 
ELSE '[
    ![](./icons/square.svg)
](/dispositif/disponible.sql?id='||dispositif.id||')' 
END as Coordonnateur
FROM dispositif order by dispo;
 

