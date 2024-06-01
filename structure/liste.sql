SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'3';

-- Liste des dispositifs
SELECT 'table' as component,
  'Structures' AS title,
  TRUE as small,
  'icone' as icon;
SELECT 
  CASE WHEN type='Lycée'
    THEN'building-community' 
    WHEN type='Collège' THEN 'building-community'
    ELSE 'building-cottage'      
    END as icone,
  type || ' ' || nom_etab AS Nom,
  etab_UAI AS UAI,
  group_concat(DISTINCT classe order by classe) as Classes
FROM structure join etab on structure.etab_UAI=etab.UAI group by etab_UAI;
 

