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
    case when :Etablissement is null 
        then 'Suivant'
        else 'Créer un élève'
    end as validate,
    case when :Etablissement is null
        then ''
        else 'eleve.sql'
    end as action,
    'green'           as validate_color,
    'Recommencer'           as reset;
-- 1ère étape:    
    SELECT 'Nom' AS label, 'user' as prefix_icon, 'nom' AS name, CAST(:nom AS text) as value, 4 as width, TRUE as required;
    SELECT 'Prénom' AS label, 'user' as prefix_icon, 'prenom' AS name, CAST(:prenom AS text) as value, 4 as width, TRUE as required;
    SELECT 'Sexe' AS label, 'friends' as prefix_icon, 'sexe' AS name, CAST(:sexe AS text) as value, 'select' as type, '[{"label": "F", "value": "F"}, {"label": "M", "value": "M"}]' as options, 1 as width;
    SELECT 'Date de naissance' AS label, 'calendar-month' as prefix_icon, 'naissance' AS name, :naissance as value, 'date' as type, 3 as width;

    SELECT 'Adresse' AS label, 'address-book' as prefix_icon, 'adresse' AS name, CAST(:adresse AS text) as value, 'text' as type, 6 as width;
    SELECT 'Code Postal' AS label, 'mail' as prefix_icon, 'zipcode' AS name, CAST(:zipcode AS text) as value, 'text' as type, 2 as width;
    SELECT 'Commune' AS label, 'building-community' as prefix_icon, 'commune' AS name, CAST(:commune AS text) as value, 'text' as type, 4 as width;
    SELECT 'INE' AS label, 'barcode' as prefix_icon, 'ine' AS name, CAST(:ine AS text) as value, 'text' as type, 3 as width;
    SELECT 'Etablissement' AS name, 'select' as type,case when :Etablissement is null then 9 else 5 end as width, CAST(:Etablissement AS INTEGER) as value, json_group_array(json_object("label", nom_etab, "value", id)) as options FROM (select nom_etab, id FROM etab union all
   select 'Aucun' as label, NULL as value
 ORDER BY nom_etab ASC);
 -- 2nde étape:
    SELECT 'Niveau' AS name, 'select' as type, 2 as width, json_group_array(json_object("label", niv, "value", niv)) as options FROM (select niv, niv FROM niveaux union all
   select '-' as label, NULL as value ORDER BY niv ASC) having :Etablissement is not null;
    SELECT 'Classe' AS label, 'select' as type, 'classe' AS name, 2 as width, json_group_array(json_object('value', classe, 'label', classe)) as options from structure where etab_id= CAST(:Etablissement AS INTEGER) having :Etablissement is not null;
    SELECT 'Référent' AS name, 'select' as type, 3 as width,
    json_group_array(json_object("label" , nom_ens_ref, "value", id )) as options FROM (select nom_ens_ref, id FROM referent union all
   select 'Aucun' as label, NULL as value ORDER BY nom_ens_ref ASC) having :Etablissement is not null;
    SELECT 'Commentaire' AS label,'textarea' as type, 'comm_eleve' AS name where :Etablissement is not null;
    
    -- Enregistrer l'élève créé dans la base
 INSERT INTO eleve(nom, prenom, naissance, sexe, adresse, code_postal, commune, INE, etab_id, UAI, niveau, classe, referent_id, comm_eleve) SELECT $nom, $prenom, $naissance, $sexe, $adresse ,$zipcode, $commune, $ine, :Etablissement, (SELECT UAI from etab where etab.id=:Etablissement), :Niveau, $classe, :Référent, $comm_eleve WHERE $classe IS NOT NULL;

-- Liste des élèves
-- (we put it after the insertion because we want to see new accounts right away when they are created)
SELECT 'list' as component;
SELECT nom||' '||prenom as title, coalesce(type,'-')||' '||coalesce(nom_etab,'-')||' ('||coalesce(classe,'-')||')' as description,
    'notification.sql?id=' || eleve.id AS link
FROM eleve LEFT JOIN etab on eleve.etab_id=etab.id ORDER by eleve.id DESC;

