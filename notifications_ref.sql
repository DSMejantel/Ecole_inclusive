SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'etablissement.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;

-- écrire le nom du référent dans le titre de la page
SELECT 
    'datagrid' as component;
SELECT 
    'Referent - MDA/MDPH : ' as title,
    nom_ens_ref||' '||prenom_ens_ref as description, 'orange' as color, 1 as active
      FROM referent WHERE referent.id = $id;
SELECT 
    CASE WHEN $group_id>2 
    THEN    tel_ens_ref
    ELSE 'numéro masqué'
    END as title,
    email as description
      FROM referent WHERE referent.id = $id;
      
-- create a temporary table to preprocess the data
create temporary table if not exists Ref_notif(notif_id, eleve_id, etab_nom, Dpt, droits_ouverts, droits_fermes, datefin);
delete  from Ref_notif; 
insert into Ref_notif
SELECT 
notification.id notif_id,
notification.eleve_id as eleve_id,
etab.nom_etab as etab_nom,
notification.Departement as Dpt,
CASE WHEN datefin>datetime(date('now')) THEN group_concat(DISTINCT modalite.type) ELSE '-' END as droits_ouverts,
CASE WHEN datefin<datetime(date('now')) THEN group_concat(DISTINCT modalite.type) ELSE '-' END as droits_fermes,
datefin as datefin
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id Where referent.id=$id group by notification.id;

-- Liste des notifications
SELECT 'table' as component,
    'actions' as markdown,
    1 as sort,
    'Fin_de_droit' as markdown,
    1 as search;
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      Ref_notif.Dpt as Dpt,
    group_concat(distinct Ref_notif.droits_ouverts) as Droits,
    CASE
       WHEN group_concat(distinct Ref_notif.droits_fermes) <> '-' THEN   '[
    ![](./icons/alert-octagon.svg)
](/ "Fin de droit pour : '||group_concat(distinct Ref_notif.droits_fermes)||'")' 
    ELSE '' END as Fin_de_droit,
    --    group_concat(distinct Ref_notif.droits_fermes) as Fin_de_droit,
    Ref_notif.etab_nom as Établissement,
    strftime('%d/%m/%Y',(SELECT max(datefin) FROM Ref_notif WHERE Ref_notif.eleve_id=eleve.id)) AS Fin,  
    CASE
       WHEN (SELECT max(datefin) FROM Ref_notif WHERE Ref_notif.eleve_id=eleve.id) < datetime(date('now')) THEN 'red'
       WHEN (SELECT max(datefin) FROM Ref_notif WHERE Ref_notif.eleve_id=eleve.id) < datetime(date('now', '+350 day')) THEN 'orange'
       ELSE 'green'
    END AS _sqlpage_color,
  '[ ![](./icons/briefcase.svg) ](notification.sql?id=' || eleve.id || ')' ||
  coalesce('[ ![](./icons/user-plus.svg) ](aesh_suivi.sql?id=' || suivi.aesh_id || '&tab=Profils)',
                 '  ![](./icons/user-off.svg) ') as actions
FROM Ref_notif LEFT JOIN eleve on Ref_notif.eleve_id = eleve.id LEFT JOIN suivi on eleve.id=suivi.eleve_id GROUP BY eleve.id ORDER BY eleve.nom, eleve.prenom;

-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter' as title,
    'notifications_ref' as filename,
    'file-download' as icon,
    'green' as color;
SELECT 
     eleve.nom as Nom,
      eleve.prenom as Prénom,
   group_concat(DISTINCT modalite.type) as Droits,
  etab.nom_etab as Établissement,
  nom_ens_ref as Référent,
  strftime('%d/%m/%Y',datefin) AS Fin  
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id Where referent.id=$id GROUP BY notification.eleve_id ORDER BY eleve.nom ASC;
