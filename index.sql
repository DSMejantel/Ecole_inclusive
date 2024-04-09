SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));    

SELECT 'dynamic' AS component, 
CASE WHEN COALESCE(sqlpage.cookie('session'), '')='' or $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties; 

---- Ligne d'identification de l'utilisateur et de son mode de connexion
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN 'Non connecté'
        ELSE 'Mon profil' 
        END as title,
    'parametres.sql?tab=Profil' as link,
    'user-circle' as icon,
    'orange' as outline; 
 
     
SELECT 'text' AS component;
SELECT
'orange' as color,
COALESCE((SELECT
    format('Connecté en tant que %s %s (mode : %s)',
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

-------Sous-Menu
select 
    'button' as component,
    'lg'     as size,
    'center' as justify,
    'pill'   as shape;
select 
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
    'Tableau de bord' as title,
    'parametres.sql?tab=Tableau de bord' as link,
    'tool' as icon,
    'green' as outline;    

SELECT 
    'Établissements' as title,
    'etablissement.sql' as link,
    'building-community' as icon,  
    'green' as outline; 
    
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
     FROM etab JOIN user_info on user_info.etab=etab.id WHERE $group_id=1 GROUP BY etab.id;
select 
    'Fiches des classes' as title,
    'users-group' as icon,
    'green' as color,
    'etab_classes_print.sql?id=' || user_info.etab ||'&classe_select=' as link
     FROM etab JOIN user_info on user_info.etab=etab.id WHERE $group_id=1 GROUP BY etab.id;   
select 
    'Élèves' as title,
    'users-group' as icon,
    'green' as color,
    'eleves_etab.sql' as link
    WHERE $group_id=1; 
    
SELECT 'hero' as component,
'École Inclusive' as title,
    'Pôle d''Appui à la Scolarité' as description,
    './Logo.png' as image;
    

