SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

   -- Mettre à jour l'AESH modifié dans la base ASEH
 UPDATE aesh SET aesh_name=:nom, aesh_firstname=:prenom, tel_aesh=:tel, courriel_aesh=:email, quotite=:quotite, tps_mission=:tps_mission, tps_ULIS=:tps_ULIS, tps_synthese=:tps_synthese WHERE id=$id and :nom is not null;
    -- Mettre à jour le compte modifié dans la base
 UPDATE user_info SET nom=:nom, prenom=:prenom, etab=:Etablissement, tel=:tel, courriel=:email WHERE username=$username and :nom is not null
 RETURNING 
 'redirect' as component,
 'aesh_suivi.sql?id='||$id as link;

