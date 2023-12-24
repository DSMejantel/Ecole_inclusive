SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'referent.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  

-- Set a variable 
SET var_eleve = (SELECT count(eleve.referent_id) FROM eleve where eleve.referent_id=$id); 
--SELECT 'text' AS component, 'Hello ' || $var_eleve AS contents; 

SELECT 
    'alert' as component,
    'Alerte' as title,
 
CASE WHEN $var_eleve::int>=1 
THEN 'Cet enseignant suit des élèves. Suppression impossible.'
ELSE 'Ce référent va être supprimé. Toute suppression est définitive !' 
END as description,
 
CASE WHEN $var_eleve::int>=1 
THEN 'hand-stop'
ELSE 'alert-triangle' 
END   as icon,
 
CASE WHEN $var_eleve::int>=1 
THEN 'yellow'
ELSE 'red' 
END     as color;
      
-- Isolement du référent dans une liste
SELECT 'table' as component,
        'Actions' as markdown,
    'nom_ens_ref' as Nom,
    'prenom_ens_ref' as Prénom,
    'tel_ens_ref' as Téléphone,
    'email' as courriel;
   
SELECT 
  nom_ens_ref AS Nom,
  prenom_ens_ref AS Prénom,
  tel_ens_ref as Téléphone,
  email as courriel,
  CASE WHEN $var_eleve::int>=1 
THEN
'[
    ![](https://tabler-icons.io/static/tabler-icons/icons/trash-off.svg)
]() ' 
ELSE
      '[
    ![](https://tabler-icons.io/static/tabler-icons/icons/trash.svg)
](referent_delete_confirm.sql?id='||$id||') ' 
END 
as Actions
FROM referent Where referent.id=$id;

SELECT 
    'hero' as component,
    '/referent.sql' as link,
    'Retour à la liste' as link_text;
