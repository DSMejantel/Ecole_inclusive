SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<'3';


--


-- ajouter une photo
insert into documents (eleve_id, doc_type, datation, doc_url)
values (
    $id,
    :type,
    :datation,
    sqlpage.persist_uploaded_file('doc', 'documents', 'pdf,jpg,jpeg,png,gif,webp')
)
returning 
'redirect' AS component,
'notification.sql?id='||$id||'&tab=Documents' as link;

-- If the insert failed, warn the user
select 'alert' as component,
    'red' as color,
    'alert-triangle' as icon,
    'Erreur de chargement' as title,
    'Essayez une nouvelle fois avec un fichier au format pdf de taille plus réduite.' as description;

