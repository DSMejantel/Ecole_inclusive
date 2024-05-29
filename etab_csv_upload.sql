-- créé par Thierry Munoz

SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';


-- temporarily store the data in a table with text columns
create temporary table if not exists etab_tmp(type text, UAI text, nom_etab text, Lon text, Lat text, description text);
delete from etab_tmp;

-- copy the data from the CSV file into the temporary table
copy etab_tmp (type, UAI, nom_etab, Lon, Lat, description) from 'comptes_data_input'
with (header true, delimiter ',', quote '"'); -- all the options are optional;

INSERT OR IGNORE INTO etab (type, UAI, nom_etab, Lon, Lat, description)
select type, UAI, nom_etab, Lon, Lat, description from etab_tmp;


SELECT
    'redirect' AS component,
    'etablissement.sql?upload=1' AS link;
    

--select 'debug' as component, $etablissement_UAI as x;
