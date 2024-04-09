SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id::int<>'4';
        
 -- Supprime le mot de passe
UPDATE user_info set password_hash = NULL WHERE username=$id and :code is not null        

   -- Mettre à jour le compte modifié dans la base avec un code d'activation
 UPDATE user_info SET activation=:code WHERE username=$id and :code is not null
 RETURNING
   'redirect' AS component,
   'parametres.sql?tab=Comptes' as link;
   
