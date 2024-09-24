SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET group_bouton=$group_id;

select 
    'title'   as component,
    'Planifier un ESS' as contents,
    3         as level;

-- Formulaire pour ajouter une intervention
SELECT 'form' as component, 
    'index.sql?ess=1' as action,
    'Ajouter' as validate,
    'green'           as validate_color;
    
    SELECT 'Date' AS label, 'horodatage' AS name, 'date' as type, (select date('now')) as value, 4 as width;
    SELECT 'Élève' AS label, 'eleve' AS name, 'select' as type, TRUE as searchable, 6 as width, json_group_array(json_object("label", nom||' '||prenom, "value", id)) as options FROM (select * FROM eleve ORDER BY nom ASC);

    SELECT 'Notes' AS label, 'notes' AS name, 'textarea' as type, TRUE as required, 12 as width;
    



