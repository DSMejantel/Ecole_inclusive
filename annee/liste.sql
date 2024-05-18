SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Liste des dispositifs
SELECT 'table' as component,
  'Années scolaires' AS title,
  'icone' as icon,
  'Active' as markdown;
SELECT 
  'calendar-month' as icone,
  annee AS Année,
CASE WHEN active::int=1
    THEN '[
    ![](./icons/select.svg)
]()' 
ELSE '[
    ![](./icons/square.svg)
](/annee/active.sql?annee='||annee.annee||' "activer comme année en cours")' 
END as Active
FROM annee;
 

