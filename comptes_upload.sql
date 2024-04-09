SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';


-- temporarily store the data in a table with text columns
create temporary table if not exists user_tmp(username text, nom text, prenom text, tel text, courriel text, groupe text, activation text, etab integer);
delete from user_tmp;

-- copy the data from the CSV file into the temporary table
copy user_tmp (username, nom, prenom, tel, courriel, groupe, activation, etab) from 'comptes_data_input'
with (header true, delimiter ',', quote '"'); -- all the options are optional;

-- Préparer l'analyse du nombre d'enregistrements importés
SET USER1 = (SELECT count(username) from user_info);
SET USER2 = (SELECT count(username) from user_tmp);

-- insert the data into the final table
INSERT OR IGNORE INTO user_info (username, nom, prenom, tel, courriel, groupe, activation, etab, password_hash)
select username, nom, prenom, tel, courriel, CAST(groupe AS integer), activation, etab, '$argon2id$v=19$m=19456,t=2,p=1$1sY4ksaDovz/IlaAwQHO/g$Wxf2S29maUh1kXZv5aNRLC71dpFkYNmHt7MOS9yMKeA'   from user_tmp;

SET USER3 = (SELECT count(username) from user_info);
SET USER4 = $USER3- $USER1

SELECT
    'redirect' AS component,
    'create_user_import_message.sql?imp='||$USER4||'&up='||$USER2 AS link;
    
