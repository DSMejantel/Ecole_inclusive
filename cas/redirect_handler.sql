-- The CAS server will redirect the user to this URL after the user has authenticated
-- This page will be loaded with a ticket parameter in the query string, which we can read in the variable $ticket

-- If we don't have a ticket, go back to the CAS login page
select 'redirect' as component, 'login.sql' as link where $ticket is null;

-- We must then validate the ticket with the CAS server
-- CAS v3 specifies the following URL for ticket validation (see https://apereo.github.io/cas/6.6.x/protocol/CAS-Protocol-Specification.html#28-p3servicevalidate-cas-30)
-- https://cas.example.org/p3/serviceValidate?ticket=ST-1856339-aA5Yuvrxzpv8Tau1cYQ7&service=http://myclient.example.org/myapp&format=JSON
SET ticket_url =
    (SELECT serveur FROM cas_service) 
        || '/p3/serviceValidate'
        || '?ticket=' || sqlpage.url_encode($ticket)
        || '&service=' || sqlpage.protocol() || '://' || sqlpage.header('host') || '/cas/redirect_handler.sql'
        || '&format=JSON';

-- We must then make a request to the CAS server to validate the ticket
set validation_response = sqlpage.fetch($ticket_url);

-- If the ticket is invalid, the CAS server will return a 200 OK response with a JSON object like this:
-- { "serviceResponse": { "authenticationFailure": { "code": "INVALID_TICKET", "description": "..." } } }
select 'redirect' as component,
    'login.sql' as link
where $validation_response->'serviceResponse'->'authenticationFailure' is not null;

-- If the ticket is valid, the CAS server will return a 200 OK response with a JSON object like this:
-- { "serviceResponse": { "authenticationSuccess": { "user": "username", "attributes": { "attribute": "value" } } } }
-- You can use the following SQL code to inspect what the CAS server returned:
--select 'debug' as component, $validation_response;
set cas_id=$validation_response->'serviceResponse'->'authenticationSuccess'->>'user'
set cas_user=coalesce((SELECT username from user_info where user_info.CAS=$cas_id),'inconnu')
--select 'text' as component, $cas_id as contents;

-- Redirect the user to the home page
select 'redirect' as component, 
       '../index.sql?cas_user=0' as link
WHERE $cas_user='inconnu';

insert into login_session(id, username, user_cas, token)
values(
        sqlpage.random_string(32),
        $cas_user,
        $cas_id,
        $ticket
)    
returning 
    'cookie' as component, 
    CASE 
      WHEN EXISTS (SELECT $cas_id FROM user_info)
      THEN 'session' END as name, 
      id as value;
      --FALSE AS secure; -- You can remove this if the site is served over HTTPS.

-- remove the session cookie
select 'cookie' as component, 'session' as name, true as remove where $cas_user='inconnu';
-- remove the session from the database
delete from login_session where id = sqlpage.cookie('session')  and $cas_user='inconnu';

-- Enregistrer la date de la connexion
SET connect = (SELECT datetime(current_timestamp, 'localtime'));
UPDATE user_info SET connexion=$connect WHERE username = $cas_user;


SELECT 'dynamic' AS component, 
sqlpage.read_file_as_text('connexion.json')    AS properties; 
-- Redirect the user to the home page
select 
    'steps'  as component,
    TRUE     as counter,
    'green' as color;
select 
    'Authentification serveur' as title,
    'network'             as icon;
select 
    'Connexion établie'    as title,
    'plug-connected'                  as icon,
    TRUE                     as active;
select 
    'École Inclusive' as title,
    'briefcase' as icon;

SELECT 'button' as component,
       'center' as justify;
SELECT 
'Poursuivre vers École Inclusive' as title,
'../index.sql'as link;
