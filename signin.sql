SELECT 'dynamic' AS component, 
json_object(
    'component', 'shell',
    'title', 'Pôle d''Appui à la Scolarité',
    'footer', 'Source : Webmestre / Collège Henri Bourrillon / Mende -2023',
    'link', '/',
    'icon', 'home',
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

SELECT 'form' AS component,
    'Connexion' AS title,
    'se connecter' AS validate,
    'login.sql' AS action;

SELECT 'username' AS name, 'Identifiant' as label, 6 as width;
SELECT 'password' AS name, 'Mot de passe' as label, 'password' AS type, 6 as width;

