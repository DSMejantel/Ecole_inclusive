SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

  
--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste des AESH' as title,
    'aesh.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline; 
select 
    'Retour à la fiche AESH' as title,
    'aesh_suivi.sql?id='|| $id as link,
    'user-plus' as icon,
    'green' as outline; 

-- écrire le nom de l'AESH dans le titre de la page
SELECT 
    'datagrid' as component;
SELECT 
    'AESH'||' - '||'Quotité : ' || quotite || ' h' as title,
    aesh_name||' '||aesh_firstname as description, 'orange' as color, 1 as active
     FROM aesh WHERE aesh.id = $id;
SELECT 
        tel_aesh as title,
    courriel_aesh as description
      FROM aesh WHERE aesh.id = $id;

    
-- Formulaire pour ajouter un emploi du temps
select 'form' as component, 'Charger l''emploi du temps (format image)' as title, 'upload_edt.sql?id='||$id as action;
select 'file' as type, 'Image' as name, 'image/*' as accept;


    


