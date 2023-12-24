    INSERT INTO user_info (username, password_hash, nom, prenom, groupe, tel, courriel)
    VALUES (:username, sqlpage.hash_password(:password), :nom, :prenom, :groupe, :tel, :courriel)
    ON CONFLICT (username) DO NOTHING
    RETURNING 
     'redirect' AS component,
    'create_user_welcome_message.sql?username=' || :username AS link;

-- If we are still here, it means that the user was not created
-- because the username was already taken.
SELECT 'redirect' AS component, 'create_user_welcome_message.sql?error&username=' || :username AS link;

