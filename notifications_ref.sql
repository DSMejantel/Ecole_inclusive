SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'etablissement.sql?restriction' AS link
        WHERE $group_id<'2';

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
    CASE WHEN $group_id<3
    THEN TRUE 
    END as disabled,
    'orange' as outline;
select 
    'Établissements' as title,
    'etab.sql' as link,
    'building-community' as icon,
    CASE WHEN $group_id<3
    THEN TRUE       
    END as disabled,
    'orange' as outline;

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
     
-- Liste des notifications
SELECT 'table' as component,
    'actions' as markdown,
    1 as sort,
    1 as search;
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      notification.Departement as Dpt,
      group_concat(DISTINCT modalite.type) as Droits,
  etab.nom_etab as Établissement,
  strftime('%d/%m/%Y',datefin) AS Fin,  
    CASE
       WHEN notification.datefin < datetime(date('now', '+1 day')) THEN 'red'
       WHEN notification.datefin < datetime(date('now', '+350 day')) THEN 'orange'
        ELSE 'green'
    END AS _sqlpage_color,
  '[ ![](./icons/briefcase.svg) ](notification.sql?id=' || eleve.id || ')' ||
  coalesce('[ ![](./icons/user-plus.svg) ](aesh_suivi.sql?id=' || suivi.aesh_id || '&tab=Profils)',
                 '  ![](./icons/user-off.svg) ') as actions
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT JOIN suivi on eleve.id=suivi.eleve_id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id Where referent.id=$id GROUP BY notification.eleve_id ORDER BY eleve.nom ASC;

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
  datefin AS Fin  
FROM notification INNER JOIN eleve on notification.eleve_id = eleve.id LEFT join notif on notif.notification_id=notification.id LEFT join modalite on modalite.id=notif.modalite_id JOIN referent on eleve.referent_id=referent.id JOIN etab on eleve.etab_id=etab.id Where referent.id=$id GROUP BY notification.eleve_id ORDER BY eleve.nom ASC;
