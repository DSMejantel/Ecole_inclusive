SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Liste des dispositifs
SELECT 'table' as component,
  'Type de notification MDA/MDPH' AS title,
  'icone' as icon;
SELECT 
  'certificate' as icone,
  type AS Modalité
FROM modalite order by type;
 
