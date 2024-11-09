SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?restriction&id='||$id AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Set variables 
SET nom_edit = (SELECT nom FROM user_info WHERE username = $id);
SET prenom_edit = (SELECT prenom FROM user_info WHERE username = $id);
SET group_edit = (SELECT groupe FROM user_info WHERE username = $id);
SET etab_edit = coalesce((SELECT :Etablissement where $etab_update=1),(SELECT etab FROM user_info WHERE username = $id));

SET classe_edit = (SELECT classe FROM user_info WHERE username = $id);
SET tel_edit = (SELECT tel FROM user_info WHERE username = $id);
SET courriel_edit = (SELECT courriel FROM user_info WHERE username = $id);
SET cas_edit = (SELECT CAS FROM user_info WHERE username = $id);

--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste des comptes' as title,
    'comptes.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  


-- Rappel du Compte concerné par la modification

SELECT 'table' as component;
SELECT 
  username as Identifiant,
  nom AS Nom,
  prenom AS Prénom,
  etab.nom_etab AS Établissement,
  classe AS Classe,
  tel as Téléphone,
  courriel as courriel
FROM user_info JOIN etab on user_info.etab=etab.id WHERE username=$id; 
  
--préciser la liste des classes suivies en réunion de synthèse   
SELECT 
    'form' as component,
    'Enregistrer' as validate,
    'equipe_confirm.sql?id='||$id as action,    
    'orange'           as validate_color;
    
SELECT 'equipe[]' as name, 'classes suivies' as label, 6 as width, 'select' as type, TRUE as required, TRUE as multiple, TRUE as dropdown,
     'Les classes connues sont déjà sélectionnées.' as description,
     json_group_array(json_object("label", classe, 
     "value", structure.id,
     'selected', equipe_synthese.classe_id is not null
     )) as options  
     FROM structure
     Left Join equipe_synthese on equipe_synthese.classe_id=structure.id 
     AND equipe_synthese.username=$id WHERE structure.etab_id=(SELECT etab from user_info WHERE username=$id);

--Bouton supprimer les classes
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'supprimer toutes les inclusions' as title,
    'equipe_delete_confirm.sql?id='||$id||'&username='||$id as link,
    'trash' as icon,
    'red' as outline;    


