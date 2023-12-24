SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

--
-- Set a variable 
SET nom_edit = (SELECT nom FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET prenom_edit = (SELECT prenom FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET user_edit = (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET tel_edit = (SELECT tel FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET courriel_edit = (SELECT courriel FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
/*SELECT 'text' AS component,
$nom_edit as contents;*/

--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour au tableau de bord' as title,
    'parametres.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  
-- Rappel info user
SELECT 'text' AS component,
COALESCE((SELECT
    format('Connecté en tant que %s %s (Rappel de l''identifiant : %s)',
            user_info.prenom,
            user_info.nom,
            user_info.username)
    FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')
), 'Non connecté') AS contents;    

/*   -- Mettre à jour le compte modifié dans la base
 UPDATE user_info SET nom=$nom, prenom=$prenom, tel=$tel, courriel=$courriel WHERE username=$user_edit and $nom is not null;
      -- Mettre à jour le référent modifié dans la base AESH
 UPDATE referent SET nom_ens_ref=$nom, prenom_ens_ref=$prenom, tel_ens_ref=$tel, email=$courriel WHERE username=$user_edit and $nom is not null;
     -- Mettre à jour l'AESH modifié dans la base AESH
 UPDATE aesh SET aesh_name=$nom, aesh_firstname=$prenom, tel_aesh=$tel, courriel_aesh=$courriel WHERE username=$user_edit and $nom is not null 
 RETURNING
   'text' AS component,
   'Compte mis à jour. [Retour au tableau de bord](parametres.sql)' as contents_md;
*/    

-- Compte concerné par la modification
SELECT 
    'alert' as component,
    'Alerte' as title,
    'Visualiser les changements opérés' as description,
    'alert-triangle' as icon,
    'green' as color;
    
SELECT 'table' as component,
    'nom' as Nom,
    'prenom' as Prénom,
    'tel' as Téléphone,
    'courriel' as courriel;
SELECT 
  nom AS Nom,
  prenom AS Prénom,
  tel as Téléphone,
  courriel as courriel
FROM user_info WHERE username=$user_edit;    

--- Formulaire de Mise à jour

SELECT 
    'form' as component,
    'comptes_user_confirm.sql?user_edit='||$user_edit as action,
    'Mettre à jour' as validate;
    
    SELECT 'Nom' AS label, 'nom' AS name, $nom_edit as value;
    SELECT 'Prénom' AS label, 'prenom' AS name, $prenom_edit as value;
    SELECT 'Téléphone' AS label, 'tel' AS name, $tel_edit as value;
    SELECT 'Courriel' AS label, 'courriel' AS name, $courriel_edit as value;

/*
   -- Mettre à jour le compte modifié dans la base
 UPDATE user_info SET nom=$nom, prenom=$prenom, tel=$tel, courriel=$courriel WHERE username=$user_edit and $nom is not null;
      -- Mettre à jour le référent modifié dans la base AESH
 UPDATE referent SET nom_ens_ref=$nom, prenom_ens_ref=$prenom, tel_ens_ref=$tel, email=$courriel WHERE username=$user_edit and $nom is not null;
     -- Mettre à jour l'AESH modifié dans la base AESH
 UPDATE aesh SET aesh_name=$nom, aesh_firstname=$prenom, tel_aesh=$tel, courriel_aesh=$courriel WHERE username=$user_edit and $nom is not null 
 RETURNING
   'text' AS component,
   'Compte mis à jour. [Retour au tableau de bord](parametres.sql)' as contents_md;
 */   
 

