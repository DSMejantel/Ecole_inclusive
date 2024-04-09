SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


--alternative
 SELECT 
    'form' as component,
    'etab_classes.sql?id=' || $id || '&classe_select=' ||$Classe AS action,
    'Valider' as validate,
    'green'           as validate_color;   
     SELECT 'Classe' AS name, 'select' as type, 12 as width, $classe_select as value, json_group_array(json_object('label', classe, 'value', classe)) as options FROM (select distinct eleve.classe as classe, eleve.classe as value FROM eleve JOIN etab on eleve.etab_id=etab.id WHERE eleve.etab_id=$id  ORDER BY eleve.classe DESC);

