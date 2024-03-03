SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;    


select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Élèves' as title,
    'briefcase' as icon,
    'green' as color;
select 
    'Ajouter un élève' as title,
    'eleve.sql' as link,
    'square-rounded-plus' as icon,
        $group_id::int<2 as disabled,
    'green' as outline;
      
-- Liste des élèves
SELECT 'table' as component,
    'Suivis' AS markdown,
    'admin' AS markdown,
    1 as sort,
    1 as search;
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      strftime('%d/%m/%Y',eleve.naissance) AS Naissance,
  eleve.classe as Classe,
  etab.nom_etab as Établissement,
      CASE 
      WHEN EXISTS (SELECT eleve.id FROM suivi WHERE suivi.eleve_id=eleve.id)
      THEN  '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||suivi.aesh_id||'&tab=Profils) [
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)' 
 WHEN EXISTS (SELECT eleve.id FROM affectation WHERE affectation.eleve_id=eleve.id)
      THEN '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)'
      ELSE
'[
    ![](./icons/alert-triangle-filled.svg)
](notification.sql?id='||eleve.id||'&tab=Profil)' 
END as Suivis, 
CASE
       WHEN EXISTS (SELECT eleve.id FROM affectation WHERE affectation.eleve_id=eleve.id) 
       THEN 'black'
       ELSE 'red'
    END AS _sqlpage_color,
CASE
WHEN $group_id::int=2 THEN
'[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil.svg)
](eleve_edit.sql?id='||eleve.id||')' 
WHEN $group_id::int=3 THEN
'[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||eleve.id||')[
    ![](./icons/pencil.svg)
](eleve_edit.sql?id='||eleve.id||')' 
ELSE
'[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil-off.svg)
]()'
END as admin
FROM eleve INNER JOIN etab on eleve.etab_id=etab.id LEFT JOIN suivi on eleve.id=suivi.eleve_id WHERE NOT EXISTS (SELECT eleve.id FROM affectation WHERE affectation.eleve_id=eleve.id) GROUP BY eleve.id ORDER BY eleve.nom ASC;

