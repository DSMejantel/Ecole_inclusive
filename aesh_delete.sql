SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Set a variable 
SET var_eleve = (SELECT count(suivi.aesh_id) FROM suivi where suivi.aesh_id=$id); 

SELECT 
    'alert' as component,
    'Alerte' as title,

-- Avertissements 
CASE WHEN $var_eleve>=1 
THEN 'Cet AESH suit des élèves. Suppression impossible.'
ELSE 'Cet AESH va être supprimé. Toute suppression est définitive !' 
END as description,

CASE WHEN $var_eleve>=1 
THEN 'hand-stop'
ELSE 'alert-triangle' 
END   as icon,
 
CASE WHEN $var_eleve>=1 
THEN 'yellow'
ELSE 'red' 
END     as color;
      
-- Isolement de l'AESH dans une liste
SELECT 'table' as component,
    'Actions' as markdown,
    'aesh_name' as Nom,
    'aesh_firstname' as Prénom,
    'tel_aesh' as Téléphone,
    'quotite' as Quotité,
    'courriel_aesh' as courriel;
   
SELECT 
aesh_name AS Nom,
  aesh_firstname AS Prénom,
  tel_aesh as Téléphone,
  courriel_aesh as courriel,
  quotite as Quotité,
  CASE WHEN $var_eleve>=1 
THEN
      '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||')[
    ![](./icons/trash-off.svg)
]() ' 
ELSE
      '[
    ![](./icons/trash.svg)
](aesh_delete_confirm.sql?id='||$id||') ' 
END 
as Actions
FROM aesh Where aesh.id=$id;

SELECT 
    'hero' as component,
    '/aesh.sql' as link,
    'Retour à la liste' as link_text;
