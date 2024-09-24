SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
--Menu


-- Liste des derniers changements
select 
    'title'   as component,
    'Dernières modifications' as contents,
    TRUE as center,
    3         as level;

    
SELECT 'table' as component,   
    'Suivis' AS markdown,
    'admin' AS markdown;
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
END as Suivis
FROM eleve LEFT JOIN suivi on eleve.id=suivi.eleve_id LEFT JOIN etab on eleve.etab_id=etab.id LEFT JOIN user_info join login_session on user_info.username=login_session.username WHERE user_info.etab=etab.id and login_session.id = sqlpage.cookie('session') and $group_id<3 GROUP BY eleve.id ORDER BY eleve.modification DESC LIMIT 5;

SELECT 
    eleve.nom as Nom,
    eleve.prenom as Prénom,
    eleve.classe as Classe,
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
WHEN $group_id=3 THEN
'[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil.svg)
](eleve_edit.sql?id='||eleve.id||')' 
WHEN $group_id=4 THEN
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
FROM eleve LEFT JOIN suivi on eleve.id=suivi.eleve_id LEFT JOIN etab on eleve.etab_id=etab.id LEFT JOIN user_info join login_session on user_info.username=login_session.username WHERE login_session.id = sqlpage.cookie('session')  and $group_id>2 GROUP BY eleve.id ORDER BY eleve.modification DESC LIMIT 5;

