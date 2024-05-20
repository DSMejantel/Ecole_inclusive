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

-- Messages d'importation
SELECT 'alert' as component,
    'Mise à jour de la base :' as title,
    'l''opération s''est déroulée correctement.' as description_md,
    'alert-circle' as icon,
    'green' as color
WHERE $update=1;
SELECT 'alert' as component,
    'Importation dans la base :' as title,
    'l''opération s''est déroulée correctement.' as description_md,
    'alert-circle' as icon,
    'green' as color
WHERE $upload=1;

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
        $group_id<3 as disabled,
    'green' as outline;
    
 select 
    'text' as component,
   '##### Légende :
![Cartable](./icons/briefcase.svg) Dossier de l''élève /  ![Incomplet](./icons/alert-triangle-filled.svg) Dossier incomplet /  ![Examens](./icons/school.svg) Aménagements d''examen /  ![AESH](./icons/user-plus.svg) Présence AESH 
' as contents_md;
      
-- Liste des élèves
SELECT 'table' as component,
    TRUE    as hover,
    TRUE    as small,
    'Suivis' AS markdown,
        'Aménagement' AS markdown,
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
](aesh_suivi.sql?id='||suivi.aesh_id||'&tab=Profils "Fiche AESH") [
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil "Dossier élève")' 
 WHEN EXISTS (SELECT eleve.id FROM affectation WHERE affectation.eleve_id=eleve.id)
      THEN '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil "Dossier élève")'
      ELSE
'[
    ![](./icons/alert-triangle-filled.svg)
](notification.sql?id='||eleve.id||'&tab=Profil  "Dossier incomplet pour cet élève")' 
END as Suivis, 
CASE WHEN EXISTS (SELECT eleve.id FROM examen_eleve WHERE eleve.id = examen_eleve.eleve_id)
THEN
'[
    ![](./icons/school.svg)
](notification.sql?id='||eleve.id||'&tab=Examen "Aménagements d''examen")' 
ELSE ''
END as Suivis,
CASE
       WHEN EXISTS (SELECT eleve.id FROM affectation WHERE affectation.eleve_id=eleve.id) 
       THEN 'black'
       ELSE 'red'
    END AS _sqlpage_color,
CASE
WHEN $group_id=3 THEN
'[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil.svg "Modifier")
](eleve_edit.sql?id='||eleve.id||')' 
WHEN $group_id=4 THEN
'[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||eleve.id||' "Supprimer")[
    ![](./icons/pencil.svg)
](eleve_edit.sql?id='||eleve.id||' "Modifier")' 
ELSE
'[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil-off.svg)
]()'
END as admin
FROM eleve LEFT JOIN etab on eleve.etab_id=etab.id LEFT JOIN suivi on eleve.id=suivi.eleve_id GROUP BY eleve.id ORDER BY eleve.nom ASC;

