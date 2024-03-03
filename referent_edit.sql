SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'referent.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
    
--
-- Set a variable 
SET nom_edit = (SELECT nom_ens_ref FROM referent WHERE id = $id);
SET prenom_edit = (SELECT prenom_ens_ref FROM referent WHERE id = $id);
SET tel_edit = (SELECT tel_ens_ref FROM referent WHERE id = $id);
SET email_edit = (SELECT email FROM referent WHERE id = $id);
-- Rappel nom du référent en cours de modification 
SELECT 'text' AS component, 'Modification de : ' || $nom_edit || ' ' || $prenom_edit AS contents;

--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste des référents' as title,
    'referent.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  
/*    
   -- Mettre à jour le référent modifié dans la base
 UPDATE referent SET nom_ens_ref=$nom, prenom_ens_ref=$prenom, tel_ens_ref=$tel, email=$email WHERE id=$id and $nom is not null;
     -- Mettre à jour le compte modifié dans la base
 UPDATE user_info SET nom=$nom, prenom=$prenom, tel=$tel, courriel=$email WHERE username=$username and $nom is not null;
*/ 
/*     -- Référent concerné
SELECT 
    'alert' as component,
    'Alerte' as title,
    'Visualiser les changements opérés' as description,
    'alert-triangle' as icon,
    'green' as color;
    
SELECT 'table' as component,
    'nom_ens_ref' as Nom,
    'prenom_ens_ref' as Prénom,
    'tel_ens_ref' as Téléphone,
    'email' as courriel;
SELECT 
      nom_ens_ref as Nom,
      prenom_ens_ref as Prénom,
      tel_ens_ref as Téléphone,
      email as courriel
FROM referent WHERE referent.id=$id;
 
 
--- Formulaire de Mise à jour
SELECT 
    'alert' as component,
    'Alerte' as title,
    'Version antérieure :' as description,
    'alert-triangle' as icon,
    'red' as color;
*/    
SELECT 
    'form' as component,
    'Mettre à jour' as validate,
    'referent_edit_confirm.sql?id='||$id||'&username='||$username as action,
    'orange'           as validate_color;
    
    SELECT 'Nom' AS label, 'user' as prefix_icon, 'nom' AS name, $nom_edit as value, 6 as width;
    SELECT 'Prénom' AS label, 'user' as prefix_icon, 'prenom' AS name, $prenom_edit as value, 6 as width;
    SELECT 'Téléphone' AS label, 'phone' as prefix_icon, 'tel' AS name, CHAR(10), $tel_edit as value, 6 as width;
    SELECT 'Courriel' AS label, 'mail' as prefix_icon, 'email' AS name, $email_edit as value, 6 as width;
 

