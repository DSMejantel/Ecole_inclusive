SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
--Sous-menu
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'Enseignant-Référent' as title,
    'referent.sql' as link,
    'writing' as icon,
    'orange' as outline;
select 
    'type de Notification' as title,
    'modalite.sql' as link,
    'certificate-2' as icon,
    CASE WHEN $group_id<2
    THEN TRUE 
    END as disabled,
    'orange' as outline;
select 
    'Dispositifs' as title,
    'dispositif.sql' as link,
    'lifebuoy' as icon,
    'Orange' as color,
    'orange' as outline;
select 
    'Établissements' as title,
    'etab.sql' as link,
    'building-community' as icon,
    CASE WHEN $group_id<2
    THEN TRUE       
    END as disabled,
    'orange' as outline;
     
-- Liste des notifications
SELECT 'table' as component,
    'nom' as Nom,
    'prenom' as Prénom,
    'datefin' as Fin,
    'nom_ens_ref' as Référent,
    'etab' as Établissement,
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
        CASE
       WHEN EXISTS (SELECT eleve.id FROM suivi WHERE suivi.eleve_id=eleve.id) THEN
      '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||')[
    ![](./icons/user-plus.svg)
]()' 
ELSE
 '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||')[
    ![](./icons/user-off.svg)
]()' 
END as Suivis
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id GROUP BY notification.eleve_id ORDER BY eleve.nom ASC;
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
