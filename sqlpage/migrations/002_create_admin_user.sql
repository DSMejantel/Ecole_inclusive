-- Creates an initial user called 'admin'
-- with a password hash that was generated using the 'generate_password_hash.sql' page.
INSERT INTO user_info (username, password_hash, nom, prenom, groupe)
VALUES ('admin', '$argon2i$v=19$m=16,t=2,p=1$YWRtaW43NDQ4$4YHFHIibnbbvwiRItp7TVw', 'admin', 'admin',3);
