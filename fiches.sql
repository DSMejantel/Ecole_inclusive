SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, 
CASE WHEN $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties; 
    
--Bouton 
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape
        WHERE $group_id>'2';
select 
    'Ajouter' as title,
    'upload_fiche_form.sql' as link,
    'square-plus' as icon,
    'green' as outline
    WHERE $group_id>'2';
    

SELECT 'list' as component,
'Pas de fiches disponibles'      as empty_title;
SELECT 
titre as title, 
contenu||
' ['||coalesce(tag,' ')||']'
||' - créé le '|| strftime('%d/%m/%Y',created_at)||' par '||prenom||' '||nom as description_md,
fiche_url as view_link
FROM fiche join user_info on user_info.username=fiche.auteur;



