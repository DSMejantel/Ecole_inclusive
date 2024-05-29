SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';


-- temporarily store the data in a table with text columns
create temporary table if not exists eleve_tmp(nom text, prenom text, naissance date, sexe text, INE text, adresse text, code_postal text, commune text, classe text, niveau text);
delete from eleve_tmp;

-- copy the data from the CSV file into the temporary table
copy eleve_tmp (nom, prenom, naissance, sexe, INE, adresse, code_postal, commune, classe, niveau) from 'comptes_data_input'
with (header true, delimiter ';', quote '"'); -- all the options are optional;

-- récupération identité de l'établissement
SET etablissement_UAI = (SELECT UAI FROM etab WHERE id = $etablissement_id);

-- insert the data into the final table
INSERT OR IGNORE INTO eleve (nom, prenom, naissance, sexe, INE, adresse, code_postal, commune, etab_id, UAI, classe, niveau)
select nom, prenom, naissance, sexe, INE, adresse, code_postal, commune, CAST($etablissement_id as Integer) as value, CAST($etablissement_UAI as text) as value, classe, niveau  from eleve_tmp;

SELECT
    'redirect' AS component,
    'eleves.sql?upload=1' AS link;
    
