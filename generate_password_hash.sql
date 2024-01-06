SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Outil de création de mot de passe
SELECT 'form' AS component;
SELECT 'password' AS name, 'Password to create a hash for' AS label, :password AS value;

SELECT 'code' AS component;
SELECT sqlpage.hash_password(:password) AS contents;

--Bouton retour
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Liste des Comptes' as title,
    'comptes.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline; 
select 
    'Tableau de bord' as title,
    'parametres.sql?tab=Comptes' as link,
    'arrow-back-up' as icon,
    'green' as outline;
