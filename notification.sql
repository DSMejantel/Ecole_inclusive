SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
 
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET group_bouton=$group_id;

SELECT 'redirect' AS component,
        'etablissement.sql?restriction' AS link
FROM eleve WHERE (SELECT user_info.etab FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') and user_info.etab<>eleve.etab_id)  and eleve.id=$id;

--Menu
SELECT 'dynamic' AS component, 
CASE WHEN $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties; 
            
-- A placer après l'affichage du menu  
-- Vérification fiche réservée aux coordonnateurs
SET coordo = (SELECT sum(DISTINCT coordo) from eleve LEFT JOIN affectation on affectation.eleve_id=eleve.id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id where eleve.id=$id);

-- Ouverture exceptionnelle de droits pour le professeur principal de la classe        
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username join eleve WHERE login_session.id = sqlpage.cookie('session') and eleve.id=$id and user_info.classe<>eleve.classe), (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username join eleve WHERE login_session.id = sqlpage.cookie('session') and eleve.id=$id and user_info.classe is null), (coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE login_session.id = sqlpage.cookie('session') and $coordo=1),3)));

-- Ouverture exceptionnelle de droits pour l'équipe des réunions de synthèse        
SET classe_eleve_id = (SELECT structure.id FROM structure JOIN eleve WHERE eleve.etab_id=structure.etab_id and eleve.classe=structure.classe and eleve.id=$id);
SET group_synthese = coalesce((SELECT equipe_synthese.classe_id FROM equipe_synthese LEFT join user_info on  user_info.username=equipe_synthese.username  LEFT join login_session on user_info.username=login_session.username WHERE login_session.id = sqlpage.cookie('session') and equipe_synthese.classe_id=$classe_eleve_id), 0);
  


-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
    'alert-circle' as icon,
    TRUE as important,
    'orange' as color
WHERE $restriction IS NOT NULL;   

-- Mets à jour les infos de dernières modifications de l'élève	
SET edition = (SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') )
SET modif = (SELECT datetime(current_timestamp, 'localtime'))

-- ajouter une notification à l'élève 
INSERT INTO notification(eleve_id, origine, Departement, datedeb, datefin, acces)
SELECT $id, :origine, :dpmt, :datedeb, :datefin, :acces WHERE :datefin IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and :datefin IS NOT NULL;

-- attribuer différents droits et aménagements sur la notification
SET notif = (SELECT last_insert_rowid() FROM notification);
INSERT INTO notif(notification_id, eleve_id, modalite_id)
    SELECT 
    $notif as notification_id,
    $id as eleve_id,
    CAST(value AS integer) as modalite_id from json_each(:modalite) WHERE :modalite IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and :modalite IS NOT NULL;

-- Insère l'affectation à un dispositif
INSERT INTO affectation(eleve_id, dispositif_id)
SELECT
$id as eleve_id,
CAST(value AS integer) as dispositif_id from json_each(:dispositif) WHERE :dispositif IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and :dispositif IS NOT NULL; 

-- Insère l'aménagement d'examen dans la base
INSERT INTO examen_eleve(eleve_id, code_id)
SELECT
$id as eleve_id,
CAST(value AS integer) as code_id from json_each(:mesure) WHERE :mesure IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and :mesure IS NOT NULL; 

-- Insère le suivi dans la base
INSERT INTO suivi(eleve_id, aesh_id, temps, mut, ind, mission)
SELECT 
	$id as eleve_id, 
	:AESH as aesh_id, 
	:temps as temps, 
	:mutualisation as mut, 
	:individuel as ind,
	:mission as mission	
	WHERE :temps IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and :temps IS NOT NULL; 	
	
-- Insère aménagement dans la base
INSERT INTO amenag(eleve_id, amenagements, objectifs, info)
SELECT 
	$id as eleve_id, 
	:amenagements as amenagements, 
	:objectifs as objectifs, 
	:info as info	
	WHERE :objectifs IS NOT NULL;
UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and :objectifs IS NOT NULL;

-- Insère dans l'historique du parcours
SET annee_en_cours=(SELECT annee FROM annee WHERE active=1)

DELETE FROM parcours WHERE eleve_id=$id and annee_id=$annee_en_cours;

INSERT INTO parcours (annee_id, eleve_id, etab_id, niveau, classe, dispositif_id, referent_id, aesh_id)
SELECT 
	$annee_en_cours as annee_id,
	$id as eleve_id,
	eleve.etab_id as etab_id,
	eleve.niveau as niveau,
	eleve.classe as classe,
	group_concat(DISTINCT dispositif.dispo) as dispositif_id,
	(SELECT SUBSTR(prenom_ens_ref, 1, 1) ||'. '||nom_ens_ref FROM referent JOIN eleve on referent.id=eleve.referent_id WHERE eleve.id=$id) as referent_id,
	(SELECT SUBSTR(aesh_firstname, 1, 1) ||'. '||aesh_name FROM aesh LEFT JOIN suivi on aesh.id=suivi.aesh_id JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.id=$id) as aesh_id
	FROM eleve LEFT JOIN affectation on affectation.eleve_id=eleve.id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.id=$id;
	
-- Insère note et info de l'historique dans la base
INSERT INTO intervention(eleve_id, horodatage,nature,notes, tracing, verrou)
SELECT 
	$id as eleve_id, 
	:horodatage as horodatage, 
	:nature as nature, 
	:notes as notes,
        coalesce(:important,0) as tracing,
        coalesce(:verrou,0) as verrou        
	WHERE $intervention=1;

UPDATE intervention SET horodatage=:horodatage,	nature=:nature, notes=:notes, tracing=coalesce(:important,0) WHERE intervention.id=$intervention_id and $intervention=2;

UPDATE eleve SET modification=$modif, editeur=$edition WHERE id=$id and $intervention IS NOT NULL;
	
-- Menu spécifique élève : modifier, ajouter notif, ajouter suivi
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Fiche' as title,
    'pencil' as icon,
    'red' as outline,
        $group_id<3 as disabled,
    'eleve_edit.sql?id='||$id as link FROM eleve where eleve.id=$id;
select 
    '+ Photo' as title,
    'camera-plus' as icon,
    'red' as outline,
        $group_bouton<4 as disabled,
    'upload_form.sql?id='||$id as link FROM eleve where eleve.id=$id;
/*    
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;*/
select 
    '+ Docs' as title,
    'upload_documents_form.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    'book' as icon,
    'orange' as outline;
select 
    '+ Notification' as title,
    'notif_ajout.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    'certificate' as icon,
    'orange' as outline;
select 
    '+ Examen' as title,
    'suivi_examen_ajout.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    'school' as icon,
    'orange' as outline;
select 
    '+ Dispositif' as title,
    'dispo_ajout.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    'lifebuoy' as icon,
    'orange' as outline;
select 
    '+ Aménagement' as title,
    'amenag_ajout.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    'list-check' as icon,
    'orange' as outline;
select 
    '+ Suivi' as title,
    'suivi_ajout.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    'user-plus' as icon,
    'orange' as outline;
select 
    '+ Inclusion' as title,
    'inclusion_ajout.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    'circles-relation' as icon,
    'orange' as outline;

-- écrire le nom de l'élève dans le titre de la page
SELECT 
    'datagrid' as component,
    CASE WHEN EXISTS (SELECT eleve.id FROM image WHERE eleve.id=image.eleve_id)
  THEN image_url 
  ELSE './icons/profil.png'
  END as image_url,
    UPPER(nom) || ' ' || prenom as title,
    'INE : '||coalesce(INE,'-') as description
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id;
SELECT 
     CASE WHEN sexe="M" THEN 'gender-male' WHEN sexe="F" THEN 'gender-female' ELSE '' END as icon,
     adresse||' '||code_postal||' '||commune as title,
    CASE WHEN sexe="F" THEN 'née le : '||strftime('%d/%m/%Y',eleve.naissance) ELSE 'né le : '||strftime('%d/%m/%Y',eleve.naissance) END  as description, 
    'black' as color,
    0 as active
    FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id;
SELECT 
    'Dispositif(s) :' as title,
    1 as active,
    group_concat(DISTINCT dispositif.dispo)   as description, 'orange' as color,
    'etab_dispositifs.sql?id='||etab.id as link
    FROM eleve INNER JOIN etab on eleve.etab_id=etab.id LEFT JOIN affectation on affectation.eleve_id=eleve.id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.id = $id;
select 
    etab.type||' '||etab.nom_etab||' ( UAI : '||etab.UAI||' )' as title,
    CASE WHEN classe<>coalesce('Aucune','') AND NOT EXISTS (SELECT $id FROM inclusion WHERE $id=inclusion.eleve_id)
    THEN 'Classe : ' || classe
    WHEN classe<>coalesce('Aucune','') AND EXISTS (SELECT $id FROM inclusion WHERE $id=inclusion.eleve_id)
    THEN 'Classe : ' || classe ||' ('|| coalesce((SELECT group_concat(classe) FROM structure JOIN inclusion on structure.id=inclusion.classe_id WHERE inclusion.eleve_id = $id),'')||')' 
    ELSE 'Niveau : ' || (SELECT niv FROM niveaux JOIN eleve on niveaux.niv=eleve.niveau WHERE eleve.id = $id)
    END as description,
    1 as active, 'green' as color,
    'etab_classes.sql?id='||etab.id||'&classe_select='||eleve.classe as link
    FROM eleve JOIN etab on eleve.etab_id=etab.id WHERE eleve.id = $id;

-- Informations sur la dernière intervention     

SELECT 'text' AS component;
SELECT
'teal' as color,
1 as italics,
COALESCE((SELECT
    format('Modifié par %s le : %s à %s',
            editeur,
            strftime('%d/%m/%Y',modification),
            strftime('%Hh%M',modification)
            )
    FROM eleve WHERE id = $id
), 'pas d''information sur la dernière modification') AS contents;     
     

--Onglets
SET tab=coalesce($tab,'Profil');
select 'tab' as component;

select CASE WHEN EXISTS (SELECT $id FROM documents WHERE $id=documents.eleve_id) THEN 'Document(s)' ELSE '' END as title, CASE WHEN EXISTS (SELECT $id FROM documents WHERE $id=documents.eleve_id) THEN 'book' ELSE '' END as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Documents' as link, CASE WHEN $tab='Documents' THEN 'orange' ELSE 'green' END as color;

select CASE WHEN EXISTS (SELECT $id FROM notification WHERE $id=notification.eleve_id) THEN 'Notification' ELSE '' END as title, CASE WHEN EXISTS (SELECT $id FROM notification WHERE $id=notification.eleve_id) THEN 'certificate' ELSE '' END as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Notification' as link, CASE WHEN $tab='Notification' THEN 'orange' ELSE 'green' END as color;

select CASE WHEN EXISTS (SELECT $id FROM examen_eleve WHERE $id=eleve_id) THEN 'Examen' ELSE '' END as title, CASE WHEN EXISTS (SELECT $id FROM examen_eleve WHERE $id=eleve_id) THEN 'school' ELSE '' END as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Examen' as link, CASE WHEN $tab='Examen' THEN 'orange' ELSE 'green' END as color;

select  'Aménagements' as title, 'list-check' as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Profil' as link, CASE WHEN $tab='Profil' THEN 'orange' ELSE 'green' END as color;
select  CASE WHEN EXISTS (SELECT $id FROM suivi WHERE $id=suivi.eleve_id) THEN 'Suivi' ELSE '' END as title, CASE WHEN EXISTS (SELECT $id FROM suivi WHERE $id=suivi.eleve_id) THEN 'user-plus' ELSE '' END as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Suivi' as link, CASE WHEN $tab='Suivi' THEN 'orange' ELSE 'green' END as color;
select CASE WHEN EXISTS (SELECT $id FROM suivi WHERE $id=suivi.eleve_id) THEN 'Graphique' ELSE '' END as title, CASE WHEN EXISTS (SELECT $id FROM suivi WHERE $id=suivi.eleve_id) THEN 'chart-bar' ELSE '' END as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Graphique' as link, CASE WHEN $tab='Graphique' THEN 'orange' ELSE 'green' END as color;
select  'Historique' as title, 'calendar-month' as icon, 1 as active, 'notification.sql?id='||$id||'&tab=Historique' as link, CASE WHEN $tab='Historique' THEN 'orange' ELSE 'green' END as color;


--Documents liés à l'élève
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape
    WHERE $tab='Documents';
select 
    '+ Ajouter' as title,
    'upload_documents_form.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    '' as icon,
    'orange' as outline
    WHERE $tab='Documents';    
SELECT 'list' as component,
'Pas de documents disponibles'      as empty_title WHERE $tab='Documents'
SELECT 
doc_type as title, 
' en date du '|| strftime('%d/%m/%Y',datation) as description_md,
'notification.sql?id='||$id||'&tab=Documents&doc='||documents.id as view_link
FROM documents join eleve on documents.eleve_id=eleve.id WHERE eleve.id = $id and $tab='Documents' order by datation;

select 
    'card' as component,
     1      as columns
     where $doc is not Null and $tab='Documents';
select 
    doc_url as embed,
    'iframe'         as embed_mode,
    '800'            as height
    FROM documents WHERE id=$doc and $tab='Documents';

-- Fiche des Aménagements 
-- fiche détaillée de l'élève
SELECT 'table' as component,
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
WHEN $group_id>2 THEN
    '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils "Fiche AESH")'
     END as Dispositif,
    CASE
WHEN $group_id>2 THEN
    '[
    ![](./icons/lifebuoy.svg)
](suivi_edit_dispo.sql?id='||$id||' "Modifier le dispositif")'
     END as Dispositif,
CASE WHEN NOT EXISTS (SELECT eleve.id FROM amenag WHERE eleve.id=amenag.eleve_id and $tab='Profil') and $group_id>1
     THEN '[![](./icons/pencil-plus.svg)
](amenag_ajout.sql?id=' || $id||' "Éditer")'
     ELSE ''
    END  as Actions,
    CASE
WHEN $group_id=3 THEN 
         '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||amenag.eleve_id||' "Supprimer")[
    ![](./icons/pencil.svg)
](amenag_edit.sql?id='||amenag.id||'&eleve='||amenag.eleve_id||' "Éditer")' 
WHEN $group_id=4 THEN   
         '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||amenag.eleve_id||' "Supprimer")[
    ![](./icons/pencil.svg)
](amenag_edit.sql?id='||amenag.id||'&eleve='||amenag.eleve_id||' "Éditer")' 
ELSE   
         '[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil-off.svg)
]()' 
END as Actions
  FROM eleve LEFT JOIN affectation on eleve.id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id LEFT JOIN amenag on amenag.eleve_id=eleve.id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on suivi.aesh_id = aesh.id WHERE eleve.id = $id and $tab='Profil' GROUP BY amenag.id;
  
-- Remarques éventuelles
SELECT 'table' as component, 
   'Éditer' as markdown
    WHERE $tab='Profil';
SELECT 
  CASE WHEN  LENGTH(comm_eleve)>1
  THEN comm_eleve 
  ELSE 'pas de remarque saisie dans la fiche élève'
  END AS commentaires,
   CASE WHEN $group_id>2 THEN 
  '[
    ![](./icons/pencil.svg)
](eleve_edit.sql?id='||$id||' "Éditer")'
   ELSE '[
    ![](./icons/pencil-off.svg)
]()'
  END as Éditer
  FROM eleve LEFT JOIN image on image.eleve_id=eleve.id WHERE eleve.id = $id and $tab='Profil';

-- Liste des suivis
SELECT 
    'text' as component
    WHERE $tab='Suivi';
    
SELECT 'table' as component,   
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
WHEN $group_id>2 THEN
    '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils "Fiche AESH")'
     END as Dispositif,
         CASE
WHEN $group_id>2 THEN
    '[
    ![](./icons/lifebuoy.svg)
](suivi_edit_dispo.sql?id='||$id||' "Modifier le dispositif")'
     END as Dispositif,
       CASE
WHEN $group_id=3 THEN 
         '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||suivi.eleve_id||' "Supprimer")[
    ![](./icons/pencil.svg)
](suivi_edit.sql?id='||suivi.id||'&eleve='||suivi.eleve_id||' "Éditer")' 
WHEN $group_id=4 THEN   
         '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||suivi.eleve_id||' "Supprimer")[
    ![](./icons/pencil.svg)
](suivi_edit.sql?id='||suivi.id||'&eleve='||suivi.eleve_id||' "Éditer")' 
WHEN $group_id=2 THEN 
         '[
    ![](./icons/user-plus.svg)
](aesh_suivi.sql?id='||aesh.id||'&tab=Profils "Fiche AESH")[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil-off.svg)
]()' 
ELSE   
         '[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil-off.svg)
]()' 
END as Actions
  FROM suivi INNER JOIN aesh on suivi.aesh_id = aesh.id LEFT JOIN affectation on suivi.eleve_id=affectation.eleve_id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id  WHERE suivi.eleve_id = $id and $tab='Suivi' GROUP BY suivi.id;

  
-- Liste des notifications
SELECT 
    'text' as component
        where $tab='Notification';
SELECT 'table' as component,
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
WHEN $group_id=3 THEN 
  '[
    ![](./icons/trash.svg)
](eleve_delete.sql?id='||eleve.id||')' 
WHEN $group_id=4 THEN  
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

-- Liste des aménagements d'examen
SELECT 'table' as component,
    TRUE    as hover,
    TRUE    as small
    WHERE $tab='Examen';
SELECT 
 code as Mesure,
 mesure as Description
 FROM examen_eleve JOIN examen on examen_eleve.code_id=examen.id WHERE eleve_id = $id and $tab='Examen' ORDER by code;
 
 select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape
    WHERE $tab='Examen';
 select 
    'Mettre à jour' as title,
    'suivi_edit_examen.sql?id=' || $id as link,
        $group_bouton<3 as disabled,
    'school' as icon,
    'orange' as outline
    WHERE $tab='Examen';
 select 
    'Paramètres' as title,
    'examen.sql' as link,
        $group_bouton<3 as disabled,
    'tool' as icon,
    'orange' as outline
    WHERE $tab='Examen';
    
-- Historique
-- Parcours   
SELECT 'table' as component
        where $tab='Historique';
SELECT 
	annee_id as Année,
	etab.type||' '||etab.nom_etab as Établissement,
	niveau as Niveau,
	classe as Classe,
	dispositif_id as Dispositif,
	referent_id as Référent,
	aesh_id as AESH
	FROM parcours JOIN etab on parcours.etab_id=etab.id WHERE eleve_id=$id and $tab='Historique' ORDER by annee_id;
-- Ajout info dans historique
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'end' as justify
    where $tab='Historique';
select 
    'intervention_ajout.sql?id=' || $id as link,
    'plus' as icon,
    'orange' as color,
    'Ajouter'    as tooltip,
    ''            as title
    where $tab='Historique';
    
-- Historique
SELECT 'table' as component,
	'Important' as markdown,
	'Confidentiel'  as markdown,
	'Actions' as markdown,
	TRUE as sort
        where $tab='Historique';
SELECT 
	id as _sqlpage_id,
	strftime('%d/%m/%Y',horodatage) as Date,
	nature as Nature,
	CASE WHEN verrou=1 and $group_id>2
	THEN notes
	WHEN verrou=1 and $group_synthese<>0
	THEN notes
	WHEN coalesce(verrou,0)=0
	THEN notes
	ELSE 'information masquée' END as Notes,
	CASE WHEN tracing=1
        THEN 'red' 
        WHEN verrou=1
        THEN 'vk' END as _sqlpage_color,
        
        CASE WHEN $group_id>2 and tracing=1
        THEN '[
    ![](./icons/select.svg)
](intervention_signale.sql?id='||intervention.id||'&imp=1&eleve='||eleve_id||' "Décocher")' 
       WHEN $group_id>2 and tracing=0 
       THEN '[
    ![](./icons/square.svg)
](intervention_signale.sql?id='||intervention.id||'&imp=0&eleve='||eleve_id||' "Cocher")' 
       WHEN $group_id<3 and tracing=1
        THEN '[
    ![](./icons/select.svg)](#'||intervention.id||')'
           WHEN $group_id<3 and tracing=0 
        THEN '[
    ![](./icons/square.svg)](#'||intervention.id||')' 
       END as Important,
       
        CASE WHEN $group_id>2 and verrou=1
        THEN '[
    ![](./icons/lock.svg)
](intervention_verrou.sql?id='||intervention.id||'&verrou=1&eleve='||eleve_id||' "Déverrouiller")' 
       WHEN $group_id>2 and coalesce(verrou,0)=0
       THEN '[
    ![](./icons/lock-open-2.svg)
](intervention_verrou.sql?id='||intervention.id||'&verrou=0&eleve='||eleve_id||' "Verrouiller")' 
       WHEN $group_id<3 and verrou=1
        THEN '[
    ![](./icons/lock.svg)](#'||intervention.id||')' 
       WHEN $group_id<3 and coalesce(verrou,0)=0
        THEN '[
    ![](./icons/lock-open-2.svg)](#'||intervention.id||')' 
END as Confidentiel,

       CASE WHEN $group_id>2 THEN 
         '[
    ![](./icons/trash.svg)
](intervention_delete.sql?id='||intervention.id||'&eleve='||eleve_id||' "Supprimer")[
    ![](./icons/pencil.svg)
](intervention_edit.sql?id='||intervention.id||'&eleve='||eleve_id||' "Éditer")' 
       ELSE   
         '[
    ![](./icons/trash-off.svg)
]()[
    ![](./icons/pencil-off.svg)
]()' 
END as Actions
	FROM intervention WHERE eleve_id=$id and $tab='Historique' ORDER by horodatage;

