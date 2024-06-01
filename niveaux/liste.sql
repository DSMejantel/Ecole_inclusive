SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'3';

-- Liste des dispositifs
SELECT 'table' as component,
  'Niveaux de scolarité' AS title,
  TRUE as small,
  'icone' as icon;
SELECT 
  'stairs' as icone,
  niv AS Niveaux
FROM niveaux order by niv;
 

