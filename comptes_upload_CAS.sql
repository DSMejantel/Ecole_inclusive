SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<>'4';


-- temporarily store the data in a table with text columns
create temporary table if not exists user_tmp(username text, CAS text);
delete from user_tmp;

-- copy the data from the CSV file into the temporary table
copy user_tmp (username, CAS) from 'comptes_data_input'
with (header true, delimiter ',', quote '"'); -- all the options are optional;


-- insert the data into the final table
UPDATE user_info 
SET CAS=(SELECT CAS from user_tmp WHERE user_tmp.username=user_info.username);


SELECT
    'redirect' AS component,
    'comptes.sql?CAS=update' AS link;
    
