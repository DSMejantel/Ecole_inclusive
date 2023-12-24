SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;

select 
    'button' as component,
    'lg'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'Vue d''ensemble et paramétrage' as title,
    'orange' as outline;
        
--Onglets
SET tab=coalesce($tab,'Tableau de bord');
select 'tab' as component;
select  'Tableau de bord'  as title, 'tool' as icon, 1  as active, CASE WHEN $tab='Tableau de bord' THEN 'orange' ELSE 'green' END as color;
select  'Carte' as title, 'map' as icon, 0 as active, CASE WHEN $tab='Carte' THEN 'orange' ELSE 'green' END as color;
select  'Paramètres' as title, 'tool' as icon, 1 as active, CASE WHEN $tab='Paramètres' THEN 'orange' ELSE 'green' END as color;
select  'Profil' as title, 'user-circle' as icon, 1 as active, CASE WHEN $tab='Profil' THEN 'orange' ELSE 'green' END as color;
select  'Comptes' as title, 'user-circle' as icon, CASE WHEN $tab='Comptes' THEN 'orange' ELSE 'green' END as color;

---- Ligne d'identification de l'utilisateur et de son mode de connexion
SELECT 'text' AS component
    where $tab='Profil';
SELECT
'green' as color,
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
), 'Non connecté') AS contents
    where $tab='Profil';

 -- Boutons administration du profil
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'start' as justify
    where $tab='Profil';
select 
    'Éditer mon Compte' as title,
    'comptes_user.sql' as link,
    'user-filled' as icon,
    'green' as outline
    where $tab='Profil';
select 
    'Changer mon mot de passe' as title,
    'comptes_user_password.sql' as link,
    'lock' as icon,
    'green' as outline
    where $tab='Profil';

-- Profil
SET user_edit = (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'table' as component,
    'nom' as Nom,
    'prenom' as Prénom,
    'tel' as Téléphone,
    'courriel' as courriel
        where $tab='Profil';
SELECT 
  username as Identifiant,
  nom AS Nom,
  prenom AS Prénom,
  tel as Téléphone,
  courriel as courriel
FROM user_info WHERE username=$user_edit
    and $tab='Profil';
    
 -- Boutons administration des comptes
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'start' as justify
    where $tab='Comptes';
select 
    'Nouveau Compte' as title,
    'comptes_ajout.sql' as link,
    'square-rounded-plus' as icon,
    $group_id::int<3 as disabled,
    'red' as outline
    where $tab='Comptes';
select 
    'Comptes' as title,
    'comptes.sql' as link,
    'user-circle' as icon,
    $group_id::int<3 as disabled,
    'red' as outline
    where $tab='Comptes';
select 
    'Accentuation' as title,
    'tool_accent_01.sql' as link,
    'tool' as icon,
    $group_id::int<3 as disabled,
    'orange' as outline
    where $tab='Comptes';
    
-- Tableau de bord 
select 
    'button' as component,
    'lg'     as size,
    'pill'   as shape,
    'center' as justify
        where $tab='Tableau de bord';
select 
    'Tableau de bord' as title,
    'tool' as icon,
    'orange' as outline
        where $tab='Tableau de bord';
    
SELECT 
    'text' as component,
    ' ' as contents_md
        where $tab='Tableau de bord';

-- Compteurs
-- Set a variable 
SET NB_ref = (SELECT count(referent.id) FROM referent Where referent.id>1);
SET NB_mod = (SELECT count(notification.id) FROM notification);
SET NB_etab = (SELECT count(etab.id) FROM etab);
SET NB_aesh = (SELECT count(aesh.id) FROM aesh Where aesh.id<>1);
SET NB_eleve = (SELECT count(eleve.id) FROM eleve);

select 
    'button' as component,
    'lg'     as size,
    'pill'   as shape,
    'center' as justify
    where $tab='Tableau de bord';
select 
    CASE WHEN $NB_ref > 1 
    THEN $NB_ref ||' référents MDPH' 
    ELSE $NB_ref ||' référent MDPH' 
    END as title,
        'lime' as color,
        'referent.sql' as link,
    TRUE     as space_after
    where $tab='Tableau de bord';

select 
    CASE WHEN $NB_etab > 1 
    THEN $NB_etab || ' établissements scolaires' 
    ELSE $NB_etab || ' établissement scolaire' 
    END as title,
    'green' as color,
    'etab.sql' as link,
    TRUE     as space_after
    where $tab='Tableau de bord';
select 
    CASE WHEN $NB_aesh > 1 
    THEN $NB_aesh  ||' accompagnants'
    ELSE $NB_aesh  ||' accompagnant'
    END as title,
    'teal' as color,
    'aesh.sql' as link,
    TRUE     as space_after
    where $tab='Tableau de bord';
select 
    CASE WHEN $NB_eleve > 1 
    THEN $NB_eleve ||' élèves' 
    ELSE $NB_eleve ||' élève' 
    END as title,
    'cyan' as color,
    'eleves.sql' as link,
           TRUE as space_after
           where $tab='Tableau de bord';       

-- Menu
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify
    where $tab='Paramètres';
select 
    'Référent' as title,
    'referent.sql' as link,
    'writing' as icon,
    'Orange' as color,
    'orange' as outline
    where $tab='Paramètres';
select 
    'type de Notification' as title,
    'modalite.sql' as link,
    'certificate-2' as icon,
    'Orange' as color,
    'orange' as outline
                where $tab='Paramètres';
select 
    'Dispositifs' as title,
    'dispositif.sql' as link,
    'lifebuoy' as icon,
    'Orange' as color,
    'orange' as outline
                where $tab='Paramètres';
select 
    'Établissements' as title,
    'etablissement.sql' as link,
    'building-community' as icon,
    'orange' as outline
            where $tab='Paramètres';
select 
    'Accompagnants' as title,
    'aesh.sql' as link,
    'user-plus' as icon,
    'orange' as outline
            where $tab='Paramètres';
select 
    'Gestion des élèves' as title,
    'eleves.sql' as link,
    'users-group' as icon,
    'orange' as outline
            where $tab='Paramètres';

--- Menu ajouter

select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify
    where $tab='Paramètres';
select 
    'Référent' as title,
    'referent_ajout.sql' as link,
    'square-rounded-plus' as icon,
    'green' as outline,
        $group_id::int<2 as disabled,
    TRUE     as space_after
    where $tab='Paramètres';
select 
    'type de Notification' as title,
    'modalite_ajout.sql' as link,
    'square-rounded-plus' as icon,
    'green' as outline,
        $group_id::int<2 as disabled,
        TRUE     as space_after
        where $tab='Paramètres';
select 
    'Dispositifs' as title,
    'dispositif_ajout.sql' as link,
    'square-rounded-plus' as icon,
    'green' as outline,
        $group_id::int<2 as disabled,
        TRUE     as space_after
        where $tab='Paramètres';
select 
    'Établissements' as title,
    'etab_ajout.sql' as link,
    'square-rounded-plus' as icon,
    'green' as outline,
        $group_id::int<2 as disabled,
            TRUE     as space_after
            where $tab='Paramètres';
select 
    'Accompagnants' as title,
    'aesh_ajout.sql' as link,
    'square-rounded-plus' as icon,
    'green' as outline,
        $group_id::int<2 as disabled,
        TRUE     as space_after
        where $tab='Paramètres';
select 
    'Ajouter des élèves' as title,
    'eleve.sql' as link,
    'square-rounded-plus' as icon,
    'green' as outline,
        $group_id::int<2 as disabled,
            TRUE     as space_after
            where $tab='Paramètres';


--    
SELECT 
    'text' as component,
    '
| Enseignants-référents | Types de Notifications  | Établissements  |  Accompagnants  |  Élèves  |
| ---- | ---- | ---- | ---- | ---- |
| Identité et coordonnées des enseignants-référents MDPH qui assurent les suivis de scolarisation. | Tous les dispositifs attribués par la MDPH, mais aussi des aménagements propres à chaque étéblissement. | Écoles, collèges et lycées du secteur avec leurs coordonnées géographiques. |Identité et coordonnées des Accompagnants des élèves. |Identité et informations sur les élèves nécessitant suivi et/ou aménagements. |

' as contents_md
where $tab='Paramètres';

--Carte   
SET AVG_Lat = (SELECT AVG(Lat) FROM etab WHERE type<>'---');
SET AVG_Lon = (SELECT AVG(Lon) FROM etab WHERE type<>'---');

SELECT 
    'map' as component,
    12 as zoom,
    400 as height,
    $AVG_Lat as latitude,
    $AVG_Lon as longitude 
    where $tab='Carte';

SELECT
    type || ' ' || nom_etab as title,
    Lat AS latitude, 
    Lon AS longitude,
        CASE WHEN  type='Lycée'   THEN'red'
    WHEN type='Collège' THEN 'orange'
    ELSE 'yellow' 
    END as color,
    CASE WHEN type='Lycée'
    THEN'building-community' 
    WHEN type='Collège' THEN 'building-community'
    ELSE 'building-cottage'      
    END as icon,
    'etab_notif.sql?id=' || id as link
    FROM etab
    where $tab='Carte';  
