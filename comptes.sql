SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'4';
    
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Importation terminée' as title,
    'Les identifiants CAS ont été importés.' 
    as description_md,
    TRUE as dismissible,
    'alert-circle' as icon,
    'green' as color
WHERE $CAS IS NOT NULL;

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

-- Liste   
SELECT 'table' as component,
        'Admin' as markdown,
    TRUE    as hover,
    TRUE    as striped_rows,
    TRUE    as small,
    1 as sort,
    1 as search;
SELECT 
  username as _sqlpage_id,
  nom AS Nom,
  prenom AS Prénom,
  username as Identifiant,
  CASE WHEN groupe=1 THEN 'consultation Enseignant'
                WHEN groupe=2 THEN 'consultation AESH'
                WHEN groupe=3 THEN 'édition'
                WHEN groupe=4 THEN 'administration'
  END as Permissions,
    etab.nom_etab as Établissement,
    classe as Classe,
  activation as Code,
  connexion as Connexion,
      '[
    ![](./icons/circles-relation.svg)
](equipe_ajout.sql?id='||username||')
      [
    ![](./icons/pencil.svg)
](comptes_edit.sql?id='||username||')[
    ![](./icons/trash.svg)
](comptes_delete.sql?id='||username||')' as Admin
FROM user_info LEFT JOIN etab on user_info.etab=etab.id WHERE username<>'admin' ORDER BY nom ASC;   
