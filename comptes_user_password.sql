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
 UPDATE user_info SET  password_hash=sqlpage.hash_password(:password) WHERE username=$user_edit and :password is not null
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
    'comptes_user_password_confirm.sql?user_edit='||$user_edit as action,
    'Mettre à jour' as validate;
    
   SELECT 'Nouveau mot de passe' AS label, 'password' AS name, 'password' AS type, '^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[-+!*$@%_])([-+!*$@%_\w]{8,15})$' AS pattern, 'Le mot de passe doit comporter au moins 8 caractères : au moins une lettre, au moins un chiffre et un caractère spécial parmi $ @ % * + - _ ! ' AS description;


