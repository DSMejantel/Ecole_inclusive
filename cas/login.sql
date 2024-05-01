SET etat=coalesce((SELECT etat FROM cas_service),0);

SELECT 'redirect' AS component,
CASE WHEN 
$etat<>1
THEN '../index.sql?cas=0' 
ELSE
    (SELECT serveur FROM cas_service)
    || '/login?service=' || sqlpage.protocol() || '://' || sqlpage.header('host') || '/cas/redirect_handler.sql'
END    as link;
