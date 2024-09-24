SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component,
sqlpage.read_file_as_text('connexion.json')  AS properties where $group_id=0;

SELECT 'dynamic' AS component,
sqlpage.read_file_as_text('index.json')  AS properties where $group_id=1;

SELECT 'dynamic' AS component,
sqlpage.read_file_as_text('menu.json')  AS properties where $group_id>1;

set id_ent = coalesce((select user_cas from login_session where id = sqlpage.cookie('session')),'inactif');

---- Ligne d'identification de l'utilisateur et de son mode de connexion
SELECT 'text' AS component;
SELECT
'orange' as color,
COALESCE((SELECT
    format('Connexion pour %s %s (MODE : %s)',
            user_info.prenom,
            user_info.nom,
            CASE groupe
                WHEN 1 THEN 'consultation Enseignant'
                WHEN 2 THEN 'consultation AESH'
                WHEN 3 THEN 'édition'
                WHEN 4 THEN 'administration'
            END)
    FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')
), 'L''accès aux informations de cette application nécessite d''être identifié.') AS contents;

SELECT 'alert' as component,
    'Info RGPD !' as title,
    'Vous disposez de la possibilité de modifier vos informations personnelles dans le menu "Mon compte"--> "Mon Profil".' AS description_md,
    'info-square-rounded' as icon,
    TRUE              as important,
    TRUE              as dismissible,
    'orange' as color
    WHERE $group_id>0;
  
-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' 
    as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;

-- Message si pas de serveur CAS configuré
SELECT 'alert' as component,
    'Attention !' as title,
    'Le serveur CAS n''est pas configuré. Contactez l''administrateur.' 
    as description_md,
    'alert-circle' as icon,
    'orange' as color
WHERE $cas<>1;

-- Message si utilisateur CAS 
SELECT 'alert' as component,
    'Attention !' as title,
    'Votre compte CAS ne correspond pas à un utilisateur de ce logiciel.' 
    as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $cas_user=0;

-- Insère ESS dans la base
INSERT INTO intervention(eleve_id, horodatage,nature,notes)
SELECT 
	:eleve as eleve_id, 
	:horodatage as horodatage, 
	'ESS' as nature, 
	:notes as notes
	WHERE :notes is not null and $ess=1;

-------Sous-Menu
select 
    'button' as component,
    'lg'     as size,
    'center' as justify,
    'pill'   as shape;
/*select 
    CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN 'Se connecter'
        ELSE 'Se déconnecter'
    END AS title,
    CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN 'signin.sql'
        ELSE 'logout.sql'
    END AS link,
     CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN 'login-2'
        ELSE 'logout'
    END AS icon,
        'orange' as outline; 
select 
    CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN 'Connexion ENT'
        ELSE 'Déconnexion ENT'
    END AS title,
    CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN '/cas/login.sql'
        ELSE '/cas/logout.sql'
    END AS link,
     CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN 'login-2'
        ELSE 'logout'
    END AS icon,
        'orange' as outline
        WHERE (SELECT etat FROM cas_service)=1;
*/        
        
select 
    'Tableau de bord' as title,
    'parametres.sql?tab=Tableau de bord' as link,
    'tool' as icon,
    'green' as outline
    where $group_id>1;    

SELECT 
    'Établissements' as title,
    'etablissement.sql' as link,
    'building-community' as icon,  
    'green' as outline
    where $group_id>1; 
    
select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape;
select 
    'Mon établissement' as title,
    'building-community' as icon,
    'green' as color,
    'etab_carte.sql?id=' || user_info.etab as link
     FROM etab JOIN user_info on user_info.etab=etab.id join login_session on user_info.username=login_session.username WHERE $group_id=1 and login_session.id = sqlpage.cookie('session') GROUP BY etab.id;
select 
    'Fiches des classes' as title,
    'users-group' as icon,
    'green' as color,
    'etab_classes_print.sql?id=' || user_info.etab ||'&classe_select=-' as link
    FROM etab JOIN user_info on user_info.etab=etab.id join login_session on user_info.username=login_session.username WHERE $group_id=1 and login_session.id = sqlpage.cookie('session') GROUP BY etab.id; 
select 
    'Élèves' as title,
    'users-group' as icon,
    'green' as color,
    'eleves_etab.sql' as link
    WHERE $group_id=1; 
select 
    'Calendrier ESS' as title,
    'calendar' as icon,
    'green' as color,
    'calendrier_etab.sql' as link
    WHERE $group_id=1;    

select 
    'card' as component,
    2  as columns WHERE $group_id>0;
select 
    '/accueil/calendrier_etab.sql?_sqlpage_embed' as embed WHERE $group_id>0;
select 
    '/accueil/calendrier_form.sql?_sqlpage_embed' as embed WHERE $group_id>2 and $ess=1;
select 
    '/accueil/eleves_historique.sql?_sqlpage_embed' as embed WHERE $group_id>0;

                
SELECT 'hero' as component,
'École Inclusive' as title,
    'Pôle d''Appui à la Scolarité' as description,
    './Logo.png' as image;
    

