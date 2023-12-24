SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

 UPDATE user_info SET  password_hash=sqlpage.hash_password(:password) WHERE username=$user_edit and :password is not null
 RETURNING
   'redirect' AS component,
   'parametres.sql?tab=Profil' as link;





