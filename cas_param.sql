SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Supprime l'ancien emploi du temps
DELETE FROM cas_service where $cas_config=1;
-- Enregistrer la notification dans la base
 INSERT INTO cas_service(serveur, etat) 
 SELECT $cas_url as serveur,
 $open as etat
 where $cas_config=1;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
  
-- Sous Menu Ajout/suppression dispositif
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;

select 
    'Retour' as title,
    'parametres.sql?tab=Comptes' as link,
    'arrow-back-up' as icon,
    'green' as outline;

-- Liste et ajout
select 
    'card' as component,
     2      as columns;
select 
    '/cas/liste.sql?_sqlpage_embed' as embed;
select 
    '/cas/form.sql?_sqlpage_embed' as embed;

 
