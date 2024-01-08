SELECT 'redirect' AS component,
        'signin.sql?activation' AS link
WHERE :code<>(SELECT activation FROM user_info WHERE username=:username);

SELECT 'redirect' AS component,
        'signin.sql?activation' AS link
WHERE (SELECT activation FROM user_info WHERE username=:username) is Null;
--
-- Set  variables 
SET nom_edit = (SELECT nom FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET prenom_edit = (SELECT prenom FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET user_edit = (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET tel_edit = (SELECT tel FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET courriel_edit = (SELECT courriel FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Rappel info user
SELECT 'text' AS component,
COALESCE((SELECT
    format('Activation de la connexion de %s %s (Rappel de l''identifiant : %s)',
            prenom,
            nom,
            username)
    FROM user_info WHERE username=:username
), 'Compte non reconnu') AS contents;    

SELECT 
    'alert' as component,
    'Alerte' as title,
    'La création d''un mot de passe est obligatoire lors de la 1ère connexion. Vous serez redirigés vers la page de connexion ensuite.' as description,
    'alert-triangle' as icon,
    'orange' as color; 

--- Formulaire de Mise à jour

SELECT 
    'form' as component,
    'comptes_user_activation_confirm.sql?user_edit='||:username as action,
    'Envoyer' as validate;
    
SELECT 
    'Nouveau mot de passe' AS label, 'password' AS name, 'password' AS type, 
    '^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$' AS pattern, 
    'Le mot de passe doit comporter au moins 8 caractères : au moins une lettre, au moins un chiffre et un caractère spécial parmi $ @ % * + - _ ! ' AS description;
-- envoyer le code d'activation de manière cachée pour sécuriser la page de confirmation    
select 
    'hidden'      as type,
    'code' as name,
    :code        as value;




