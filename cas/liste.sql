SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'4';

-- Liste des dispositifs
SELECT 'table' as component,
  'Serveur actuel :' AS title,
  'icone' as icon,
  'ouvert' as markdown;
SELECT 
  'lifebuoy' as icone,
  serveur AS Serveur,
  CASE WHEN etat=1
    THEN '[
    ![](./icons/select.svg)
](/cas/indisponible.sql?id='||cas_service.id||')' 
ELSE '[
    ![](./icons/square.svg)
](/cas/disponible.sql?id='||cas_service.id||')' 
END as ouvert
FROM cas_service;
 

