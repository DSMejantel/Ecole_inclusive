SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
--
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
/* 
-- En théorie l'administrateur ne devrait pas changer le mot de passe d'un utilisateur et ne devrait pas le connaître.
-- Cela reste techniquement possible en réactivant le bloc ci-dessous.
select 
    'Changer le mot de passe' as title,
    'comptes_edit_password.sql?id='||$id as link,
    'lock' as icon,
    'red' as outline;
*/  
select 
    'Nouveau code d''activation' as title,
    'comptes_edit_activation.sql?id='||$id as link,
    'lock' as icon,
    'red' as outline; 

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
    
--- Formulaire de Mise à jour
SELECT 
    'form' as component,
    '' as validate,
    'compte' as id;
    
    SELECT 'Nom' AS label, 'nom' AS name, $nom_edit as value, 4 as width;
    SELECT 'Prénom' AS label, 'prenom' AS name, $prenom_edit as value, 4 as width;
    SELECT 'Identifiant ENT' AS label, 'cas' AS name, $cas_edit as value, 4 as width;
    SELECT 'Téléphone' AS label, 'tel' AS name, $tel_edit as value, 3 as width;
    SELECT 'Courriel' AS label, 'courriel' AS name, $courriel_edit as value, 3 as width;
    SELECT 'Etablissement' AS name, 'select' as type, 2 as width, CAST($etab_edit as integer) as value, json_group_array(json_object("label", nom_etab, "value", id)) as options FROM (select nom_etab, id FROM etab union all
   select 'Aucun' as label, NULL as value
 ORDER BY nom_etab ASC);

    SELECT 'Classe' AS name, 'select' as type, 2 as width, $classe_edit as value, json_group_array(json_object('label', classe, 'value', classe)) as options FROM (select distinct classe as classe, classe as value FROM structure WHERE structure.etab_id=$etab_edit UNION ALL SELECT 'Aucune' as label, NULL as value  ORDER BY structure.classe ASC);
  

    SELECT 'Droits :' AS label, 'groupe' AS name, 'select' as type, '[{"label": "Consultant prof", "value": 1}, {"label": "Consultant AESH", "value": 2}, {"label": "Éditeur", "value": 3}, {"label": "administrateur", "value": 4}]' as options, $group_edit as value, 2 as width;

--Bouton du formulaire
select 
    'button' as component;
select 
    'compte' as form,
    'Modifier' as title,
    'comptes_edit_confirm.sql?id='||$id as link,
    'green' as color; 
select 
    'Mettre à jour les classes' as title,
    'compte' as form,
    '?etab_update=1&id='||$id as link,
    'orange' as color;  

   
 

