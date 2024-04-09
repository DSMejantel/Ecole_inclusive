SELECT 'dynamic' AS component, 
json_object(
    'component', 'shell',
    'title', 'Pôle d''Appui à la Scolarité',
    'footer', 'Source : Webmestre / Collège Henri Bourrillon / Mende -2023',
    'link', '/',
    'icon', 'home',
    'layout','fluid',
    'language','fr-FR',
    'norobot', TRUE,    
    'menu_item', json_array(
        json_object(
            'title', 'Connexion',
            'link', 'signin.sql'
                ))) 
    AS properties;

SELECT 'alert' as component,
    'Attention' as title,
    'Vous devez vous connecter pour accéder à ce contenu' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $error IS NOT NULL;

SELECT 'alert' as component,
    'Attention' as title,
    'Votre code d''activation n''est pas valable.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $activation IS NOT NULL;

SELECT 'form' AS component,
    'Connexion' AS title,
    'auth' as id,
    '' AS validate;
    --'login.sql' AS action;

SELECT 'username' AS name, 'Identifiant' as label,  'user' as prefix_icon, 4 as width;
SELECT 'password' AS name, 'Mot de passe' as label, 'password' AS type,  'lock' as prefix_icon, 'Mot de passe' as placeholder, 4 as width;
SELECT 'code' AS name, 'Code d''activation' as label, 'text' AS type,  'OU' as prefix, 'Code d''activation de 1ère connexion' as placeholder, 4 as width;

select 
    'button' as component;
select 
    'login.sql' as link,
    'auth'            as form,
    'green'          as color,
    'Me connecter'         as title;
select 
    'comptes_user_activation.sql' as link,
    'auth'         as form,
    'orange'      as color,
    'Activer mon compte'         as title;

