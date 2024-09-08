SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'parametres.sql?restriction' AS link
        WHERE $group_id<'3';


    
    -- Enregistrer l'élève créé dans la base
 INSERT INTO eleve(nom, prenom, naissance, sexe, adresse, code_postal, commune, INE, etab_id, UAI, niveau, classe, referent_id, comm_eleve) SELECT :nom, :prenom, :naissance, :sexe, :adresse ,:zipcode, :commune, :ine, :Etablissement, (SELECT UAI from etab where etab.id=:Etablissement), :Niveau, :classe, :Référent, :comm_eleve WHERE :classe IS NOT NULL
 RETURNING 
     'redirect' AS component,
    'eleve.sql' AS link;



