SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Liste des derniers changements
select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape;
select 
    'Liste des derniers changements' as title,
    'user-plus' as icon,
    'azure' as outline;
    
SELECT 'table' as component,   
    'Suivis' AS markdown,
    'admin' AS markdown,
    'nom' as Nom,
    'prenom' as Prénom,
        'temps' as Temps,
    'classe' as Classe,
    'modalite' as Suivi,
    1 as sort,
    1 as search;
SELECT 
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    strftime('le %d/%m/%Y à %Hh%M:%S', eleve.modification) as Modifié,
    eleve.editeur AS Par,
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
FROM eleve LEFT JOIN suivi on eleve.id=suivi.eleve_id GROUP BY eleve.id ORDER BY eleve.modification DESC LIMIT 20;

