SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'etablissement.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;  

-- Sous Menu 
SET page='Référents';  
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;
        
-- Sous Menu référent
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Ajouter un référent' as title,
    'referent_ajout.sql' as link,
    'square-rounded-plus' as icon,
        $group_id<3 as disabled,
        'green' as outline;

select 
    'Notifications' as title,
    'notifications.sql' as link,
    'certificate' as icon,
    'green' as outline;
---------------------------
SELECT 'table' as component,
    'Actions' as markdown,
    1 as sort,
    1 as search;
SELECT 
  nom_ens_ref AS Nom,
  prenom_ens_ref AS Prénom,
  CASE WHEN $group_id>2 
    THEN    tel_ens_ref
    ELSE 'numéro masqué'
    END as Téléphone,
  email as courriel,
CASE WHEN $group_id=3 THEN
  '[
    ![](./icons/pencil.svg)
](referent_edit.sql?id='||referent.id||') [
    ![](./icons/certificate.svg)
](notifications_ref.sql?id='||referent.id||')
[
    ![](./icons/trash-off.svg)
]()' 
WHEN  $group_id=4 THEN
  '[
    ![](./icons/pencil.svg)
](referent_edit.sql?id='||referent.id||'&username='||referent.username||') [
    ![](./icons/certificate.svg)
](notifications_ref.sql?id='||referent.id||')
[
    ![](./icons/trash.svg)
](referent_delete.sql?id='||referent.id||')' 
ELSE
  '[
    ![](./icons/certificate.svg)
](notifications_ref.sql?id='||referent.id||')
    ![](./icons/pencil-off.svg)
[
    ![](./icons/trash-off.svg)
]()' 
END 
as Actions
FROM referent WHERE prenom_ens_ref is not null; 


