-- Creates an initial values for test
INSERT INTO aesh (username, aesh_name, aesh_firstname, tel_aesh, courriel_aesh)
VALUES ('marc.durand', 'DURAND', 'Marc', '04.05.06.07.08','marc.durand@ac-libre.fr');

INSERT INTO user_info (username, password_hash, nom, prenom, groupe, connexion)
VALUES ('marc.durand', '$argon2id$v=19$m=19456,t=2,p=1$9i+xJR5+dBIUSjQxdkcSOQ$R7uIW8dT+SlHoZrq9Xacnzy8GSi5pAEqzSofT0/5zCw', 'DURAND', 'Marc',1,'2024-03-04 11:49:14');

INSERT INTO user_info (username, password_hash, nom, prenom, groupe, connexion)
VALUES ('jean.dupont', '$argon2id$v=19$m=19456,t=2,p=1$JBb/dhX+7K2zAzcwsTJ5mA$1MR2kt27toJ5IUA1uLZrniIQAhTdYKJnJX/+NRnzyvE', 'DUPONT', 'Jean',2,'2024-03-04 11:49:14');

INSERT INTO etab (type, nom_etab, Lon, Lat)
VALUES ('collège', 'Bourrillon', 3.50626824362502, 44.5204430879396);

INSERT INTO eleve(nom, prenom, naissance, etab_id, classe)
VALUES ('MARTIN', 'Kevin', '2009-01-11', 1, '6eme2');

INSERT INTO referent (username, nom_ens_ref, prenom_ens_ref, tel_ens_ref, email)
VALUES ('anne.dubois','DUBOIS', 'Anne', '04.05.06.07.09','anne.dubois@ac-libre.fr');

INSERT INTO modalite (type)
VALUES ('AESH-mut');

INSERT INTO dispositif (dispo)
VALUES ('PIAL');


