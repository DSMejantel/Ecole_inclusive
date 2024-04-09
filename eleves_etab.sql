SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET group_bouton=$group_id;

--Menu
SELECT 'dynamic' AS component, 
CASE WHEN $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties; 
    
-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;    

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
    1 as sort,
    1 as search;
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      strftime('%d/%m/%Y',eleve.naissance) AS Naissance,
  eleve.classe as Classe,
      CASE 
      WHEN EXISTS (SELECT eleve.id FROM suivi WHERE suivi.eleve_id=eleve.id)
      THEN  '[
    ![](./icons/user-plus.svg)
]() [
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
CASE WHEN EXISTS (SELECT eleve.id FROM examen_eleve WHERE eleve.id = examen_eleve.eleve_id)
THEN
'[
    ![](./icons/school.svg)
](notification.sql?id='||eleve.id||'&tab=Examen)' 
ELSE ''
END as Suivis
FROM eleve INNER JOIN etab on eleve.etab_id=etab.id LEFT JOIN suivi on eleve.id=suivi.eleve_id LEFT JOIN user_info WHERE user_info.etab=etab.id  GROUP BY eleve.id ORDER BY eleve.nom ASC;

