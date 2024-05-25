SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?restriction&id='||$id AS link
        WHERE $group_id<'4';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste des établissements' as title,
    'etablissement.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  
   

SELECT 
    'alert' as component,
    'Alerte' as title,
    'Toute suppression est définitive !' as description,
    'alert-triangle' as icon,
    'red' as color;

-- Set a variable 
SET var_eleves = (SELECT count(etab_id) FROM eleve where etab_id=$id); 

      
-- Isolement de l'établissement dans une liste
SELECT 'table' as component,
    'actions' AS markdown,
    1 as sort,
    1 as search;
    
SELECT 
  etab.nom_etab as Établissement,
  etab.UAI as UAI,
  CASE WHEN $var_eleves>=1
THEN
'[
    ![](./icons/trash-off.svg)
]() ' 
ELSE
      '[
    ![](./icons/trash.svg)
](etab_delete_confirm.sql?id='||etab.id||' "Confirmer la suppression")' 
END 
as actions
FROM etab LEFT JOIN eleve on etab.id=eleve.etab_id Where etab.id=$id group by etab.id;

-- Isolement de ses élèves dans une liste
SELECT 
    'alert' as component,
    TRUE as important,
    'ÉTABLISSEMENT avec '||$var_eleves||' élève(s) rattaché(s)' as title,
    CASE WHEN $var_eleves>=1
    THEN 'alert-triangle' 
    ELSE 'thumb-up'
    END as icon,
    CASE WHEN $var_eleves>=1
    THEN 'Il est nécessaire de supprimer les élèves avant de pouvoir supprimer l''établissement.' 
    ELSE 'Pas d''élève trouvé.'
    END as description,
    CASE WHEN $var_eleves>=1
    THEN 'orange'
    ELSE 'green'
    END as color;

