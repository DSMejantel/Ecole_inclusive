SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
--
-- Set a variable 
SET nom_edit = (SELECT aesh_name FROM aesh WHERE id = $id);
SET prenom_edit = (SELECT aesh_firstname FROM aesh WHERE id = $id);
SET etab_edit = (SELECT etab FROM user_info join aesh on aesh.username=user_info.username WHERE aesh.id = $id);
SET tel_edit = (SELECT tel_aesh FROM aesh WHERE id = $id);
SET email_edit = (SELECT courriel_aesh FROM aesh WHERE id = $id);
SET quotite_edit = (SELECT quotite FROM aesh WHERE id = $id);
SET tps_ULIS_edit = (SELECT tps_ULIS FROM aesh WHERE id = $id);
SET tps_mission_edit = (SELECT tps_mission FROM aesh WHERE id = $id);
SET tps_synthese_edit = (SELECT tps_synthese FROM aesh WHERE id = $id);

--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste des AESH' as title,
    'aesh.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline; 
select 
    'Retour à la fiche AESH' as title,
    'aesh_suivi.sql?id='|| $id as link,
    'user-plus' as icon,
    'green' as outline;  
    
-- écrire le nom de l'AESH dans le titre de la page
SELECT 
    'datagrid' as component;
SELECT 
    'AESH'||' - '||'Quotité : ' || quotite || ' h' as title,
    aesh_name||' '||aesh_firstname as description, 'orange' as color, 1 as active
     FROM aesh WHERE aesh.id = $id;
SELECT 
        tel_aesh as title,
    courriel_aesh as description
      FROM aesh WHERE aesh.id = $id;


--- Formulaire de Mise à jour
SELECT 
    'form' as component,
    'aesh_edit_confirm.sql?id='||$id||'&username='||$username as action,
    'Mettre à jour' as validate,
    'orange'           as validate_color;
    
    SELECT 'Nom' AS label, 'nom' AS name, $nom_edit as value, 'user' as prefix_icon, 6 as width;
    SELECT 'Prénom' AS label, 'prenom' AS name, $prenom_edit as value, 'user' as prefix_icon, 6 as width;
    SELECT 'Etablissement' AS name, 'select' as type, 4 as width, CAST($etab_edit as integer) as value, json_group_array(json_object("label", nom_etab, "value", id)) as options FROM (select nom_etab, id FROM etab union all
   select 'Aucun' as label, NULL as value
 ORDER BY nom_etab ASC);
    SELECT 'Téléphone' AS label, 'tel' AS name, CHAR(10), $tel_edit as value, 'phone' as prefix_icon, 4 as width;
    SELECT 'Courriel' AS label, 'email' AS name, $email_edit as value, 'mail' as prefix_icon, 4 as width;
    SELECT 'Quotité' AS label, 'quotite' AS name, 'number' AS type, $quotite_edit as value, 'calendar-time' as prefix_icon, 3 as width;
        SELECT 'Temps en ULIS' AS label, 'tps_ULIS' AS name, 'number' AS type, 0.5 as step, $tps_ULIS_edit as value, 'clock' as prefix_icon, 3 as width;
        SELECT 'Temps d''activités' AS label, 'tps_mission' AS name, 'number' AS type, 0.5 as step, $tps_mission_edit as value, 'clock-play' as prefix_icon, 3 as width;
        SELECT 'Temps de synthèse' AS label, 'tps_synthese' AS name, 'number' AS type, 0.5 as step, $tps_synthese_edit as value, 'clock-question' as prefix_icon, 3 as width;
    
 

