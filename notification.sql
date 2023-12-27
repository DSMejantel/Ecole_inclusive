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

-- Mets à jour les infos de dernières modifications de l'élève	
SET edition = (SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') )
SET modif = (SELECT datetime(current_timestamp, 'localtime'))

-- ajouter une notification à l'élève 
INSERT INTO notification(eleve_id, origine, Departement, datedeb, datefin, acces)
SELECT $id, $origine, $dpmt, $datedeb, $datefin, $acces WHERE $datefin IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and $datefin IS NOT NULL;

-- attribuer différents droits et aménagements sur la notification
SET notif = (SELECT last_insert_rowid() FROM notification);
INSERT INTO notif(notification_id, eleve_id, modalite_id)
    SELECT 
    $notif as notification_id,
    $id as eleve_id,
    CAST(value AS integer) as modalite_id from json_each($modalite) WHERE :modalite IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and :modalite IS NOT NULL;

-- Insère l'affectation à un dispositif
INSERT INTO affectation(eleve_id, dispositif_id)
SELECT
$id as eleve_id,
CAST(value AS integer) as dispositif_id from json_each($dispositif) WHERE :dispositif IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and :dispositif IS NOT NULL; 

-- Insère le suivi dans la base
INSERT INTO suivi(eleve_id, aesh_id, temps, mut, ind, mission)
SELECT 
	$id as eleve_id, 
	:AESH as aesh_id, 
	$temps as temps, 
	:mutualisation as mut, 
	:individuel as ind,
	$mission as mission	
	WHERE $temps IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and $temps IS NOT NULL; 	
	
-- Insère aménagement dans la base
INSERT INTO amenag(eleve_id, amenagements, objectifs, info)
SELECT 
	$id as eleve_id, 
	$amenagements as amenagements, 
	$objectifs as objectifs, 
	$info as info	
	WHERE $objectifs IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and $objectifs IS NOT NULL;

-- écrire le nom de l'élève dans le titre de la page
SELECT 
    'datagrid' as component,
    CASE WHEN EXISTS (SELECT eleve.id FROM image WHERE eleve.id=image.eleve_id)
  THEN image_url 
  ELSE './icons/profil.png'
  END as image_url,
    UPPER(nom) || ' ' || prenom as title
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id;
SELECT 
    'né(e) le :' as title,
    strftime('%d/%m/%Y',eleve.naissance)   as description, 'black' as color,
    0 as active
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id;
SELECT 
    'Dispositif(s) :' as title,
    1 as active,
    group_concat(DISTINCT dispositif.dispo)   as description, 'orange' as color,
    'etab_dispositifs.sql?id='||etab.id as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id LEFT JOIN affectation on affectation.eleve_id=eleve.id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.id = $id;
select 
    etab.type||' '||etab.nom_etab as title,
    'Classe : ' || classe  as description,
    1 as active, 'green' as color,
    'etab_classes.sql?id='||etab.id||'&classe_select='||eleve.classe as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id WHERE eleve.id = $id;

-- Informations sur la dernière intervention     

SELECT 'text' AS component;
SELECT
'grey' as color,
1 as italics,
COALESCE((SELECT
    format('Modifié par %s le : %s à %s',
            editeur,
            strftime('%d/%m/%Y',modification),
            strftime('%Hh%M',modification)
            )
    FROM eleve WHERE id = $id
), 'pas d''information sur la dernière modification') AS contents;     
     
-- Menu spécifique élève : modifier, ajouter notif, ajouter suivi
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Modifier l''élève' as title,
    'pencil' as icon,
    'red' as outline,
        $group_id::int<2 as disabled,
    'eleve_edit.sql?id='||$id as link FROM eleve where eleve.id=$id;
select 
    'photo' as title,
    'camera-plus' as icon,
    'red' as outline,
        $group_id::int<3 as disabled,
    'upload_form.sql?id='||$id as link FROM eleve where eleve.id=$id;
/*    
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;*/
select 
    'Ajouter notification' as title,
    'notif_ajout.sql?id=' || $id as link,
        $group_id::int<2 as disabled,
    'certificate' as icon,
    'orange' as outline;
select 
    'affecter sur dispositif' as title,
    'dispo_ajout.sql?id=' || $id as link,
        $group_id::int<2 as disabled,
    'lifebuoy' as icon,
    'orange' as outline;
select 
    'créer un aménagement' as title,
    'amenag_ajout.sql?id=' || $id as link,
        $group_id::int<2 as disabled,
    'list-check' as icon,
    'orange' as outline;
select 
    'créer un suivi' as title,
    'suivi_ajout.sql?id=' || $id as link,
        $group_id::int<2 as disabled,
    'user-plus' as icon,
    'orange' as outline;



--Onglets
SET tab=coalesce($tab,'Profil');
select 'tab' as component,
TRUE as center;
select  'Notification' as title, 'certificate' as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Notification' as link, CASE WHEN $tab='Notification' THEN 'orange' ELSE 'green' END as color;
select  'Aménagements' as title, 'list-check' as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Profil' as link, CASE WHEN $tab='Profil' THEN 'orange' ELSE 'green' END as color;;
select  'Suivi' as title, 'user-plus' as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Suivi' as link, CASE WHEN $tab='Suivi' THEN 'orange' ELSE 'green' END as color;;
select  'Graphique' as title, 'chart-bar' as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Graphique' as link, CASE WHEN $tab='Graphique' THEN 'orange' ELSE 'green' END as color;;

-- Fiche des Aménagements 
-- fiche détaillée de l'élève
SELECT 'table' as component,
    'dispositif.dispo' as Dispositif,   
    'info' as commentaires,
    'amenagements' as Aménagements,
    'objectifs' as Objectifs,
    'Dispositif' as markdown,
        'Actions' as markdown
        WHERE $tab='Profil';
  SELECT 
  CASE WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id=amenag.eleve_id and $tab='Profil') 
     THEN amenag.info
     ELSE 'non saisi'
     END AS Constats,
  CASE WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id=amenag.eleve_id and $tab='Profil') 
     THEN amenag.amenagements
     ELSE 'non saisi'
     END AS Aménagements,
  CASE WHEN EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id=amenag.eleve_id and $tab='Profil') 
     THEN amenag.objectifs
     ELSE 'non saisi'
    END  as Objectifs,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,
    CASE
WHEN $group_id::int>1 THEN
    '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils)'
     END as Dispositif,
         CASE
WHEN $group_id::int>1 THEN
    '[
    ![](./icons/lifebuoy.svg)
](suivi_edit_dispo.sql?id='||$id||')'
     END as Dispositif,
    CASE
WHEN $group_id::int=2 THEN 
         '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||amenag.eleve_id||')[
    ![](./icons/pencil.svg)
](amenag_edit.sql?id='||amenag.id||'&eleve='||amenag.eleve_id||')' 
WHEN $group_id::int=3 THEN   
         '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||amenag.eleve_id||')[
    ![](./icons/pencil.svg)
](amenag_edit.sql?id='||amenag.id||'&eleve='||amenag.eleve_id||')' 
ELSE   
         '[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil-off.svg)
]()' 
END as Actions
  FROM eleve LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN amenag on amenag.eleve_id=eleve.id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id = aesh.id WHERE eleve.id = $id and $tab='Profil';
  
-- Remarques éventuelles
SELECT 'table' as component, 
   'Éditer' as markdown
    WHERE $tab='Profil';
SELECT 
  CASE WHEN  LENGTH(comm_eleve)>1
  THEN comm_eleve 
  ELSE 'pas de remarque saisie dans la fiche élève'
  END AS commentaires,
  '[
    ![](./icons/pencil.svg)
](eleve_edit.sql?id='||$id||')'
  as Éditer
  FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id and $tab='Profil';

-- Liste des suivis
/*select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape
    WHERE $tab='Suivi';
select 
    'Liste des Suivis' as title,
    'list-check' as icon,
    'lime' as outline
    WHERE $tab='Suivi';
*/
SELECT 
    'text' as component
    WHERE $tab='Suivi';
    
SELECT 'table' as component,   
    'aesh_name' as AESH,
    'temps' as Temps,
        'mut' as mut,
    'dispositif' as Dispositif,
    'amenagements' as Aménagements,
    'objectifs' as Objectifs,
    'comm_suivi' as commentaires,
    'Dispositif' as markdown,
    'Actions' as markdown
    WHERE $tab='Suivi';
SELECT 
    SUBSTR(aesh.aesh_firstname, 1, 1) ||'. '|| aesh_name as AESH,
    temps||'h' as Temps,
    suivi.mission as Mission,
      CASE
       WHEN mut=2 THEN 'oui'
        ELSE 'non'
    END  AS Mutualisé,
      CASE
       WHEN ind=1 THEN 'oui'
        ELSE 'non'
    END  AS Individuel,
    group_concat(DISTINCT dispositif.dispo) as Dispositif,
        CASE
WHEN $group_id::int>1 THEN
    '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils)'
     END as Dispositif,
         CASE
WHEN $group_id::int>1 THEN
    '[
    ![](./icons/lifebuoy.svg)
](suivi_edit_dispo.sql?id='||$id||')'
     END as Dispositif,
       CASE
WHEN $group_id::int=2 THEN 
         '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||suivi.eleve_id||')[
    ![](./icons/pencil.svg)
](suivi_edit.sql?id='||suivi.id||'&eleve='||suivi.eleve_id||')' 
WHEN $group_id::int=3 THEN   
         '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||suivi.eleve_id||')[
    ![](./icons/pencil.svg)
](suivi_edit.sql?id='||suivi.id||'&eleve='||suivi.eleve_id||')' 
ELSE   
         '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils)[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil-off.svg)
]()' 
END as Actions
  FROM suivi INNER JOIN aesh on suivi.aesh_id = aesh.id LEFT JOIN affectation on suivi.eleve_id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id  WHERE suivi.eleve_id = $id and $tab='Suivi' GROUP BY suivi.id;


  
-- Liste des notifications
/*select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape
     where $tab='Notification';
select 
    'Historique des notifications' as title,
    'certificate' as icon,
    'lime' as outline
    where $tab='Notification';
*/
SELECT 
    'text' as component
        where $tab='Notification';
SELECT 'table' as component,
    'origine' as origine,
    'Departement' as Département,
    'acces' as accès,
    'datedeb' as Début,
    'datefin' as Fin,
    'referent' as Référent,
    'Actions' as markdown
        where $tab='Notification';
SELECT 
   CASE
       WHEN notification.datefin < datetime(date('now', '+1 day')) THEN 'red'
       WHEN notification.datefin < datetime(date('now', '+350 day')) THEN 'orange'
        ELSE 'green'
    END AS _sqlpage_color,
     CASE
       WHEN notification.origine=1 THEN 'CDAO'
       WHEN notification.origine=0 THEN 'MDPH'
    END AS Origine,
    notification.Departement as Département,
     group_concat(DISTINCT modalite.type) as Droits,
    notification.acces as accès,
   strftime('%d/%m/%Y',datedeb) AS Début,
  strftime('%d/%m/%Y',datefin) AS Fin,
  SUBSTR(referent.prenom_ens_ref, 1, 1) ||'. '||referent.nom_ens_ref as Référent,
CASE
WHEN $group_id::int=2 THEN 
  '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||eleve.id||')' 
WHEN $group_id=3 THEN  
  '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||eleve.id||')' 
ELSE  
'[
    ![](./icons/trash-off.svg)
]()' 
END as Actions
FROM notif INNER JOIN notification on notif.notification_id=notification.id join eleve on notif.eleve_id=eleve.id LEFT join modalite on modalite.id=notif.modalite_id LEFT join referent on eleve.referent_id=referent.id WHERE notif.eleve_id = $id and $tab='Notification' GROUP BY notification.id ORDER BY datefin ASC;

  
 --Graphique
SELECT 
    'chart' as component,
    'bar' as type,
    'Organisation du suivi pour '||eleve.prenom ||' '||eleve.nom as title,
    'green' as color,
    'orange' as color,
    'red' as color,
    1 as labels,
    1 as toolbar,
    1 as horizontal
    FROM suivi INNER JOIN aesh on suivi.aesh_id=aesh.id JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.id = $id and $tab='Graphique' GROUP BY eleve.id;
  SELECT 
    aesh.aesh_firstname ||' '||aesh.aesh_name as label,
    sum(coalesce(suivi.temps,0)) as value
    FROM suivi INNER JOIN aesh on suivi.aesh_id=aesh.id LEFT JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.id = $id and $tab='Graphique' GROUP BY aesh_name;




