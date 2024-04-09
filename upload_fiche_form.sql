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
    'Retour' as title,
    'fiches.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline; 

-- Formulaire pour ajouter une fiche
select 'form' as component, 'Préparer une fiche' as title, 'upload_fiche.sql' as action;
select 'text' as type, 'titre' as name, 'Titre' as label, 6 as width;
select 'text' as type, 'tag' as name, 'Mots-clés' as label, 6 as width;
select 'textarea' as type, 'contenu' as name,'Résumé' as label;
select 'file' as type, 'fiche' as name, 'Fiche (en pdf)' as label;


    


