SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id<'3';

   -- Mettre à jour l'établissement modifié dans la base
 UPDATE etab SET type=:type, nom_etab=:nom_etab, UAI=:UAI, description=:description, Lat=:Lat, Lon=:Lon WHERE id=$id and :nom_etab is not null

 
 RETURNING 
 'redirect' as component,
 'etablissement.sql' as link;
 


