SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

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
    'Orange' as color,
    'orange' as outline;
select 
    'type de Notification' as title,
    'modalite.sql' as link,
    'certificate-2' as icon,
    'Orange' as color,
    'orange' as outline;
select 
    'Aménagement d''examen' as title,
    'examen.sql' as link,
    'school' as icon,
    'Orange' as color,
    'orange' as outline;
select 
    'Dispositifs' as title,
    'dispositif.sql' as link,
    'lifebuoy' as icon,
    'Orange' as color,
    'orange' as outline;
select 
    'Établissements' as title,
    'building-community' as icon,
    'orange' as color;
select 
    'Niveaux' as title,
    'niveaux.sql' as link,
    'stairs' as icon,
    'Orange' as color,
    'orange' as outline;
    
    -- Enregistrer la notification dans la base
 INSERT INTO etab(type, nom_etab, description, Lat, Lon) SELECT $type, $nom_etab, $description, $Lat, $Lon WHERE $description IS NOT NULL;
 
 -- Fiches des établissments
 SELECT 'card' as component,
  'Établissements' AS title,
   'Liste des écoles, collèges et lycées du PIAL' AS description;
SELECT 
  type  AS description,
  'green' as color,
  description as footer,
  'building-community' as icon,
  nom_etab AS title,
  'etab_notif.sql?id=' || id as link
FROM etab;

-- Nouvel établissement    
SELECT 
    'form' as component,
    'Nouvel établissement' as title,
    'etab_ajout' as id,
    ''     as validate,
    'Recommencer' as reset;
    
    SELECT 'Catégorie' AS label, 'type' AS name, 6 as width, 'select' as type, 1 as value, '[{"label": "---", "value": "---"}, {"label": "École", "value": "école"}, {"label": "Collège", "value": "Collège"}, {"label": "Lycée", "value": "Lycée"}]' as options;
    SELECT 'Établissement scolaire' AS label, 'nom_etab' AS name, 6 as width, $search as value;
    SELECT 'Adresse' AS label, 'description' AS name;
    SELECT 'Latitude' AS label, 'Lat' AS name, 6 as width, $lat as value;
    SELECT 'Longitude' AS label, 'Lon' AS name, 6 as width, $lon as value;

select 
    'button' as component;    
select 
    'etab_ajout'         as form,
    'green'      as color,
    'square-plus' as icon,
    'Ajouter'         as title;
select 
    'etab_ajout_carte.sql' as link,
    'etab_ajout'            as form,
    'orange'          as outline,
    'world' as icon,
    'Ajouter depuis une carte'         as title;    
    


   

