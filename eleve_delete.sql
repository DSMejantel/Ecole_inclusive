SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'2';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste' as title,
    'eleves.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline;  
select 
    'Retour à la fiche élève' as title,
    'notification.sql?id='|| $id||'&tab=Profil' as link,
    'briefcase' as icon,
    'green' as outline;     

SELECT 
    'alert' as component,
    'Alerte' as title,
    'Toute suppression est définitive !' as description,
    'alert-triangle' as icon,
    'red' as color;
-- Set a variable 
SET var_suivi = (SELECT count(suivi.id) FROM suivi where suivi.eleve_id=$id); 
SET var_amenag = (SELECT count(amenag.id) FROM amenag where amenag.eleve_id=$id); 
SET var_notif = (SELECT count(notification.id) FROM notification where notification.eleve_id=$id); 
      
-- Isolement de l'élève dans une liste
SELECT 'table' as component,
    'actions' AS markdown,
    'nom' as Nom,
    'prenom' as Prénom,
    'naissance' as Naissance, 
    'classe' as Classe,
    'nom_etab' AS Établissement,
    1 as sort,
    1 as search;
    
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      strftime('%d/%m/%Y',eleve.naissance) AS Naissance,
  eleve.classe as Classe,
  etab.nom_etab as Établissement,
  CASE WHEN $var_suivi>=1 OR $var_amenag>=1 OR $var_notif>=1 
THEN
'[
    ![](./icons/trash-off.svg)
]() ' 
ELSE
      '[
    ![](./icons/trash.svg)
](eleve_delete_confirm.sql?id='||eleve.id||')' 
END 
as actions
FROM eleve LEFT JOIN etab on eleve.etab_id=etab.id Where eleve.id=$id;

-- Isolement de ses notifications dans une liste
SELECT 
    'alert' as component,
    'Alerte' as title,
    CASE WHEN $var_notif>=1
    THEN 'alert-triangle' 
    ELSE 'thumb-up'
    END as icon,
    CASE WHEN $var_notif>=1
    THEN 'Il est nécessaire de supprimer les notifications avant de pouvoir supprimer l''élève.' 
    ELSE 'Pas de notification trouvée'
    END as description,
    CASE WHEN $var_notif>=1
    THEN 'orange'
    ELSE 'green'
    END as color;
    --
SELECT 'table' as component,
    'actions' AS markdown,
    'notification.datefin' as Fin,
    'notification.modalite' as Modalité,
    'eleve.nom' as Nom, 
    'eleve.prenom' as Prénom;
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      strftime('%d/%m/%Y',datefin) AS Fin,
     group_concat(DISTINCT modalite.type) as Droits,
        '[
    ![](./icons/trash.svg)
](notif_delete_confirm.sql?id='||notification.id||'&eleve_id='||$id||') ' as actions
/*FROM notification INNER JOIN eleve on notification.eleve_id=eleve.id LEFT join notif on notif.eleve_id=eleve.id LEFT join modalite on modalite.id=notif.modalite_id  Where notification.eleve_id=$id GROUP BY notification.id ; */
FROM notif INNER JOIN notification on notif.notification_id=notification.id join eleve on notif.eleve_id=eleve.id LEFT join modalite on modalite.id=notif.modalite_id  Where notification.eleve_id=$id GROUP BY notification.id ;
-- Isolement de ses aménagements dans une liste
SELECT 
    'alert' as component,
    'Alerte' as title,
    CASE WHEN $var_amenag>=1
    THEN 'alert-triangle' 
    ELSE 'thumb-up'
    END as icon,
    CASE WHEN $var_amenag>=1
    THEN 'Il est nécessaire de supprimer les aménagements avant de pouvoir supprimer l''élève.' 
    ELSE 'Pas d''aménagement trouvé'
    END as description,
    CASE WHEN $var_amenag>=1
    THEN 'orange'
    ELSE 'green'
    END as color;
    --
SELECT 'table' as component,
    'actions' AS markdown,
    'eleve.nom' as Nom, 
    'eleve.prenom' as Prénom;
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      amenag.amenagements AS Aménagements,
      amenag.objectifs AS Objectifs,
            '[
    ![](./icons/trash.svg)
](amenag_delete_confirm.sql?id='||amenag.id||'&eleve_id='||$id||') ' as actions
FROM amenag INNER JOIN eleve on amenag.eleve_id=eleve.id Where amenag.eleve_id=$id GROUP BY amenag.id ;

-- Isolement de ses suivis dans une liste
SELECT 
    'alert' as component,
    'Alerte' as title,
    CASE WHEN $var_suivi>=1
    THEN 'alert-triangle' 
    ELSE 'thumb-up'
    END as icon,
    CASE WHEN $var_suivi>=1
    THEN 'Il est nécessaire de supprimer les suivis avant de pouvoir supprimer l''élève.' 
    ELSE 'Pas de suivi trouvé'
    END as description,
    CASE WHEN $var_suivi>=1
    THEN 'orange'
    ELSE 'green'
    END as color;
    --
SELECT 'table' as component,
    'actions' AS markdown,
    'dispositif' as Dispositif,
    'AESH_name' as AESH,
    'eleve.nom' as Nom, 
    'eleve.prenom' as Prénom;
SELECT 
      eleve.nom as Nom,
      eleve.prenom as Prénom,
      suivi.temps as Temps,
    SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '||aesh.aesh_name as AESH,
            '[
    ![](./icons/trash.svg)
](suivi_delete_confirm.sql?id='||suivi.id||'&eleve_id='||$id||') ' as actions
FROM suivi INNER JOIN eleve on suivi.eleve_id=eleve.id JOIn aesh on aesh.id=suivi.aesh_id Where suivi.eleve_id=$id GROUP BY suivi.id ;

