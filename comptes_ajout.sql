SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Formulaire
SELECT 'form' AS component,
    'Nouveau compte utilisateur' AS title,
        case when :Etablissement is null 
        then 'Suivant'
        else 'Créer le compte'
    end as validate,
    case when :Etablissement is null
        then ''
        else 'create_user.sql'
    end as action,
    'green'           as validate_color;

-- 1ère étape:
SELECT 'username' AS name, 'Identifiant' as label, CAST(:username AS text) as value, 4 as width, TRUE as required;
SELECT 'nom' AS name, 'Nom' as label, CAST(:nom AS text) as value, 4 as width, TRUE as required;
SELECT 'prenom' AS name, 'Prénom' as label, CAST(:prenom AS text) as value, 4 as width, TRUE as required;
SELECT 'Identifiant ENT' AS label, 'cas' AS name, CAST(:cas AS text) as value, 4 as width;
SELECT 'Téléphone' AS label, 'tel' AS name, CAST(:tel AS text) as value, 3 as width;
SELECT 'Courriel' AS label, 'courriel' AS name, CAST(:courriel AS text) as value, 3 as width;
SELECT 'Etablissement' AS name, 'select' as type, CAST(:Etablissement AS integer) as value, 6 as width, json_group_array(json_object("label", nom_etab, "value", id)) as options FROM (select nom_etab, id FROM etab union all
   select 'Aucun' as label, NULL as value
 ORDER BY nom_etab ASC);
-- 2nde étape:
SELECT 'Classe' AS label, 'select' as type, 'classe' AS name, 3 as width, json_group_array(json_object('value', classe, 'label', classe)) as options from structure where etab_id= CAST(:Etablissement AS INTEGER) having :Etablissement is not null;
SELECT 'groupe' AS name, 'Permissions' as label, 'select' as type, 3 as width,
    0        as value,
    '[{"label": "Consultant prof", "value": 1}, {"label": "Consultant AESH", "value": 2}, {"label": "Éditeur", "value": 3}, {"label": "administrateur", "value": 4}]' as options where :Etablissement is not null;
SELECT 'code' AS name, 'text' AS type, sqlpage.random_string(20) AS value, 'Code d''activation' as label, 6 as width, TRUE as required where :Etablissement is not null;


