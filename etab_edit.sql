SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
   
-- Set a variable 
SET cat_edit = (SELECT type FROM etab WHERE id = $id);
SET etab_edit = (SELECT nom_etab FROM etab WHERE id = $id);
SET UAI_edit = (SELECT UAI FROM etab WHERE id = $id);
SET adr_edit = (SELECT description FROM etab WHERE id = $id);
SET lat_edit = (SELECT Lat FROM etab WHERE id = $id);
SET lon_edit = (SELECT Lon FROM etab WHERE id = $id);
 
-- Nouvel établissement    
SELECT 
    'form' as component,
    'Modification de l''établissement '||(SELECT nom_etab FROM etab WHERE id = $id) as title,
    'etab_edit_confirm.sql?id='||$id as action,
    'Mettre à jour' as validate,
    'orange'           as validate_color;
    
    SELECT 'Catégorie' AS label, 'type' AS name, 3 as width, 'select' as type, $cat_edit as value, '[{"label": "---", "value": "---"}, {"label": "École", "value": "École"}, {"label": "Collège", "value": "Collège"}, {"label": "Lycée", "value": "Lycée"}]' as options, TRUE as required;
    SELECT 'Établissement scolaire' AS label, 'nom_etab' AS name, $etab_edit as value, 6 as width, TRUE as required;
    SELECT 'UAI' AS label, 'UAI' AS name, $UAI_edit as value, 3 as width, TRUE as required;
    SELECT 'Adresse' AS label, 'description' AS name, $adr_edit as value, 6 as width, TRUE as required;
    SELECT 'Latitude' AS label, 'Lat' AS name, 3 as width, $lat_edit as value;
    SELECT 'Longitude' AS label, 'Lon' AS name, 3 as width, $lon_edit as value;

   

    


   

