-- The authentication component will stop the execution of the page and redirect the user to the login page if
-- the password is incorrect or if the user does not exist.
SELECT 'authentication' AS component,
    'signin.sql?error' AS link,
    (SELECT password_hash FROM user_info WHERE username = :username) AS password_hash,
    :password AS password;

-- Analyser si il s'agit de la 1ère visite/connexion    
SET visite = (SELECT coalesce(connexion,0) FROM user_info WHERE username = :username);
SET connect = (SELECT datetime(current_timestamp, 'localtime'));

-- Generate a random 32 characters session ID, insert it into the database,
-- and save it in a cookie on the user's browser.
INSERT INTO login_session (id, username)
VALUES (sqlpage.random_string(32), :username)
RETURNING 
    'cookie' AS component,
    'session' AS name,
    id AS value,
    FALSE AS secure; -- You can remove this if the site is served over HTTPS.

-- Enregistrer la date de la connexion
UPDATE user_info SET connexion=$connect WHERE username = :username;

-- Redirect the user to the protected page.
SELECT 'redirect' AS component, 
CASE WHEN $visite::int=0
THEN 'comptes_user_password_first.sql'
ELSE 'index.sql' 
END AS link
FROM user_info;
