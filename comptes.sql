SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';
    
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
    
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'3';


select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Nouveau compte' as title,
    'comptes_ajout.sql' as link,
    'square-rounded-plus' as icon,
    'green' as outline;
select 
    'Retour' as title,
    'parametres.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;
   
SELECT 'table' as component,
        'Admin' as markdown,
    'nom' as Nom,
    'aprenom' as Prénom,
    'groupe' as Permissions,
    'username' as Identifiant,
    1 as sort,
    1 as search;
SELECT 
  nom AS Nom,
  prenom AS Prénom,
  CASE WHEN groupe='1' THEN 'consultation'
  WHEN groupe='2' THEN 'Éditeur'
  ELSE 'Administrateur'
  END as Permissions,
  username as Identifiant,
  strftime('%d/%m/%Y %H:%M',connexion) as Connexion,
      '[
    ![](./icons/pencil.svg)
](comptes_edit.sql?id='||username||')[
    ![](./icons/trash.svg)
](comptes_delete.sql?id='||username||')' as Admin
FROM user_info WHERE username<>'admin' ORDER BY nom ASC;   


