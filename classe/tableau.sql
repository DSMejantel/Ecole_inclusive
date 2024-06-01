SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        '../parametres.sql?restriction' AS link
        WHERE $group_id<'3';

-- Calcul des variables établissement
SET NB_eleve = (SELECT count(distinct eleve.id) FROM eleve where eleve.etab_id=$id and eleve.classe=$classe_select);
-- Personnalisation NB_accomp pour version classe :
SET NB_accomp = (SELECT count(distinct suivi.eleve_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE suivi.aesh_id<>1 and eleve.etab_id=$id and eleve.classe=$classe_select);
SET NB_notif = (SELECT count(notification.id) FROM notification JOIN eleve on notification.eleve_id = eleve.id WHERE eleve.etab_id = $id and eleve.classe=$classe_select);
SET NB_aesh = (SELECT count(distinct suivi.aesh_id) FROM suivi JOIN eleve on suivi.eleve_id=eleve.id WHERE eleve.etab_id=$id and eleve.classe=$classe_select and suivi.aesh_id<>1);

-- écrire les infos de l'établissement dans le titre de la page [GRILLE]
SELECT 
    'datagrid' as component;
SELECT 
    ' Élèves accompagnés : ' as title,
    $NB_accomp as description,
    'users-plus' as icon;
SELECT 
    ' Élèves à suivre : ' as title,
    $NB_eleve as description,
    TRUE           as active,
    'briefcase' as icon;
SELECT 
' AESH ' as title,
    $NB_aesh as description,
    'user-plus' as icon;
 

