SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';


-- temporarily store the data in a table with text columns
create temporary table if not exists eleve_tmp(id integer, nom text, prenom text, naissance date, sexe TEXT, INE text, adresse text, code text, commune text, etab_id integer, classe text, niveau text);
delete from eleve_tmp;

-- copy the data from the CSV file into the temporary table
copy eleve_tmp (id, nom, prenom, naissance, sexe, INE, adresse, code, commune, etab_id, classe, niveau) from 'comptes_data_input'
with (header true, delimiter ',', quote '"'); -- all the options are optional;


-- insert the data into the final table
UPDATE eleve 
SET 
nom=eleve_tmp.nom,
prenom=eleve_tmp.prenom,
naissance=eleve_tmp.naissance,
sexe=eleve_tmp.sexe,
INE=eleve_tmp.INE,
adresse=eleve_tmp.adresse,
code_postal=eleve_tmp.code,
commune=eleve_tmp.commune,
etab_id=eleve_tmp.etab_id, 
classe=eleve_tmp.classe, 
niveau=eleve_tmp.niveau 
FROM eleve_tmp
WHERE eleve_tmp.id=eleve.id;


SELECT
    'redirect' AS component,
    'eleves.sql?update=1' AS link;
    
