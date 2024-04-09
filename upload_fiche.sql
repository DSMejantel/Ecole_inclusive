SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<'3';

set user_id = (SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- ajouter une fiche
insert into fiche (titre, contenu, tag, auteur, fiche_url)
values (
    $titre,
    $contenu,
    $tag,
    $user_id,
    sqlpage.persist_uploaded_file('fiche', 'fiches', 'pdf,jpg,jpeg,png,gif,webp')
)
returning 
'redirect' AS component,
'fiches.sql' as link;

-- If the insert failed, warn the user
select 'alert' as component,
    'red' as color,
    'alert-triangle' as icon,
    'Failed to upload image' as title,
    'Please try again with a smaller picture. Maximum allowed file size is 500Kb.' as description;

