-- remove the session from the database
delete from login_session where id = sqlpage.cookie('session');
-- remove the session cookie
select 'cookie' as component, 'session' as name, true as remove;

SELECT 'redirect' AS component, '/' AS link;

/*-- log the user out of the cas server
select
    'redirect' as component,
    (SELECT serveur FROM cas_service)
    || '/logout?service=' || sqlpage.protocol() || '://' || sqlpage.header('host') || '/cas/redirect_handler.sql'
    as link;
    */
