SELECT 'dynamic' AS component, 
CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN
json_object(
    'component', 'shell',
    'title', 'Pôle d''Appui à la Scolarité',
    'footer', 'Source : Webmestre / Collège Henri Bourrillon / Mende -2023',
    'link', '/',
    'icon', 'home',
    'language','fr-FR',
    'layout', 'fluid',
    'norobot', TRUE,    
    'menu_item', json_array(
        json_object(
            'title', 'Connexion',
            'link', 'signin.sql'
                ))) 
ELSE                
                json_object(
    'component', 'shell',
    'title', 'Pôle d''Appui à la Scolarité',
    'footer', 'Source : Webmestre / Collège Henri Bourrillon / Mende -2023',
    'link', '/',
    'icon', 'home',
    'language','fr-FR',
    'layout', 'fluid',
    'norobot', TRUE,    
    'menu_item', json_array(
        json_object(
            'title', 'Élèves',
            'submenu', json_array(
                json_object(
                    'link', 'eleves.sql',
                    'title', 'Liste complète'
                ),
                json_object(
                    'link', 'eleves_attente.sql',
                    'title', 'Élèves en attente'
                ),
                json_object(
                    'link', 'eleves_historique.sql',
                    'title', 'Dernières modifications'
                ),
                json_object(
                    'link', 'eleve.sql',
                    'title', 'Ajouter un élève'
                ))),
        json_object(
            'title', 'AESH',
            'submenu', json_array(
                json_object(
                    'link', 'aesh.sql',
                    'title', 'Liste complète'
                ),
                json_object(
                    'link', 'aesh_ajout.sql',
                    'title', 'Ajouter'
                ))),   
        json_object(
            'title', 'Étab.',
            'submenu', json_group_array(
                json_object(
                    'link', 'etab_carte.sql?id='||etab.id,
                    'title', nom_etab
                ))),     
        json_object(
            'link', 'referent.sql',
            'title', 'Référent MDPH'
                ),     
        json_object(
            'title', 'Paramétrage',
            'submenu', json_array(
                json_object(
                    'link', 'parametres.sql?tab=Tableau de bord',
                    'title', 'Tableau de bord'
                ),
                json_object(
                    'link', 'parametres.sql?tab=Carte',
                    'title', 'Carte'
                ),
                json_object(
                    'link', 'parametres.sql?tab=Paramètres',
                    'title', 'Paramètres'
                )))
                , 
         json_object(
            'title', 'Mon compte',
            'submenu', json_array(
                json_object(
                    'link', 'parametres.sql?tab=Mon profil',
                    'title', 'Mon profil'
                ),
                json_object(
                    'link', 'logout.sql',
                    'title', 'Se déconnecter'
                )))    
                 )
                ) 
            END    AS properties FROM etab FULL JOIN referent on etab.id=referent.id;

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));    

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
                WHEN 1 THEN 'consulation'
                WHEN 2 THEN 'édition'
                WHEN 3 THEN 'administration'
            END)
    FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')
), 'L''accès aux informations de cette application nécessite d''être identifié.') AS contents;
  
-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
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
 
    
SELECT 'hero' as component,
'École Inclusive' as title,
    'Pôle d''Appui à la Scolarité' as description,
    './Logo.png' as image;
    

