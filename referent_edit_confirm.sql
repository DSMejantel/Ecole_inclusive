SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'referent.sql?restriction' AS link
        WHERE $group_id<'2';

   -- Mettre à jour le référent modifié dans la base
 UPDATE referent SET nom_ens_ref=$nom, prenom_ens_ref=$prenom, tel_ens_ref=$tel, email=$email WHERE id=$id and $nom is not null;
     -- Mettre à jour le compte modifié dans la base
 UPDATE user_info SET nom=$nom, prenom=$prenom, tel=$tel, courriel=$email WHERE username=$username and $nom is not null
 RETURNING
 'redirect' as component,
 'referent.sql' as link;


