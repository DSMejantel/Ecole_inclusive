SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
    
    SELECT 
    'form' as component,
    'Créer un élève' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;
    
    SELECT 'Nom' AS label, 'user' as prefix_icon, 'nom' AS name, 5 as width, TRUE as required;
    SELECT 'Prénom' AS label, 'user' as prefix_icon, 'prenom' AS name, 4 as width, TRUE as required;
    SELECT 'Date de naissance' AS label, 'calendar-month' as prefix_icon, 'naissance' AS name, 'date' as type, 3 as width;
    SELECT 'Etablissement' AS name, 'select' as type, 4 as width, json_group_array(json_object("label", nom_etab, "value", id)) as options FROM (select * FROM etab ORDER BY nom_etab ASC);
    SELECT 'Niveau' AS name, 'select' as type, 2 as width, json_group_array(json_object("label", niv, "value", id)) as options FROM (select * FROM niveaux ORDER BY niv ASC);
    SELECT 'Classe' AS label, 'users-group' as prefix_icon, 'classe' AS name, 2 as width;
    SELECT 'Référent' AS name, 'select' as type, 4 as width,
    json_group_array(json_object("label" , nom_ens_ref, "value", id )) as options FROM (select * FROM referent ORDER BY nom_ens_ref ASC);
    SELECT 'Commentaire' AS label,'textarea' as type, 'comm_eleve' AS name;
    
    -- Enregistrer l'élève créé dans la base
 INSERT INTO eleve(nom, prenom, naissance, etab_id, niveau, classe, referent_id, comm_eleve) SELECT $nom, $prenom, $naissance, :Etablissement, :Niveau, $classe, :Référent, $comm_eleve WHERE $classe IS NOT NULL;

-- Liste des élèves
-- (we put it after the insertion because we want to see new accounts right away when they are created)
SELECT 'list' as component;
SELECT nom||' '||prenom as title, type||' '||nom_etab||' ('||classe||')' as description,
    'notification.sql?id=' || eleve.id AS link
FROM eleve INNER JOIN etab on eleve.etab_id=etab.id ORDER by eleve.id DESC;

