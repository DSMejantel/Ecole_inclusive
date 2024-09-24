SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
--Bouton retour sans valider
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour à la liste' as title,
    '../etab_suivi.sql?id='||$etab||'&tab=Acc' as link,
    'arrow-back-up' as icon,
    'green' as outline;      


-- Formulaire pour ajouter un suivi
SELECT 'form' as component, 
    'Mettre en place des suivis' as title, 
    'suivi_ajout_confirm.sql?id='||$id||'&etab='||$etab as action,
    'Ajouter' as validate,
    'green'           as validate_color;
SELECT 'AESH' as name, 'select' AS type, 3 as width, json_group_array(json_object("label", username, "value", id)) as options FROM (select * FROM aesh ORDER BY aesh_name ASC);
     SELECT 'Temps de suivi hebdomadaire' AS label, 'clock' as prefix_icon, 'temps' AS name, 'number' as type, 0.5 as step, 0 as value, 3 as width;     
     SELECT 'mutualisation' as name, 'select' as type, 3 as width, '[{"label": "non", "value": 1}, {"label": "oui", "value": 2}]' as options;
     SELECT 'individuel' as name, 'select' as type, 3 as width, '[{"label": "non", "value": 0}, {"label": "oui", "value": 1}]' as options, 0 as value;
     SELECT 'Mission de l''accompagnant' as label, 'mission' as name, 'textarea' as type, 12 as width;


    


