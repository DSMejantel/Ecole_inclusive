SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;


SELECT 'hero' AS component,
     'Validé !' AS title,
   'Pour information,  le nouveau compte '|| $username ||' a bien été créé.' AS description_md,
   'referent.sql' AS link,
    'Retour à la liste' AS link_text
WHERE $error IS NULL;

SELECT 'hero' AS component,
    'Erreur !' AS title,
    'Cet identifiant existe déjà dans la base.' AS description_md,
    'referent_ajout.sql' AS link,
    'Recommencer' AS link_text
WHERE $error IS NOT NULL;
