SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu   
select 'dynamic' as component, sqlpage.run_sql('menu_parametres.sql') as properties;
     
-- Liste des notifications
SELECT 'table' as component,
    'Suivis' as markdown,
    1 as sort,
    1 as search;
SELECT 
  CASE
       WHEN notification.datefin < datetime(date('now', '+1 day')) THEN 'red'
       WHEN notification.datefin < datetime(date('now', '+350 day')) THEN 'orange'
        ELSE 'green'
    END AS _sqlpage_color,
      eleve.nom as Nom,
      eleve.prenom as Prénom,
  group_concat(DISTINCT modalite.type) as Droits,
  etab.nom_etab as Établissement,
  nom_ens_ref as Référent,
  strftime('%d/%m/%Y',datefin) AS Fin,  
  '[ ![](./icons/briefcase.svg) ](notification.sql?id=' || eleve.id || ' "Fiche élève")' ||
  coalesce('[ ![](./icons/user-plus.svg) ](aesh_suivi.sql?id=' || suivi.aesh_id || '&tab=Profils "Fiche AESH")',
                 '  ![](./icons/user-off.svg)') as Suivis
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT JOIN suivi on eleve.id=suivi.eleve_id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id GROUP BY notification.eleve_id ORDER BY eleve.nom ASC;

-- Télécharger les données
SELECT 
    'csv' as component,
    'Exporter' as title,
    'eleves' as filename,
    'file-download' as icon,
    'green' as color;
SELECT 
     eleve.nom as Nom,
      eleve.prenom as Prénom,
   group_concat(DISTINCT modalite.type) as Droits,
  etab.nom_etab as Établissement,
  nom_ens_ref as Référent,
  datefin AS Fin  
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id GROUP BY notification.eleve_id ORDER BY eleve.nom ASC;
