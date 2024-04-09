SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Bilan
SELECT 
    'alert' as component,
    'Bilan de l''importation' as title,
    'Bilan : '||$imp||' comptes ont été importés sur '||$up||' dans le fichier envoyé.' as description,
    CASE WHEN $imp=$up
    THEN 'check' 
    ELSE 'alert-circle'
    END as icon,
    CASE WHEN $imp=$up
    THEN 'green' 
    ELSE 'red'
    END as color;

--Bouton retour
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Importation' as title,
    'comptes_import.sql' as link,
    'arrow-back-up' as icon,
    'red' as outline; 
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
    
