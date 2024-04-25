SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'index.sql?restriction' AS link
        WHERE $group_id::int<>'4';


-- Mettre à jour le référent modifié dans la base AESH
 UPDATE referent SET nom_ens_ref=$nom, prenom_ens_ref=$prenom, tel_ens_ref=$tel, email=$courriel WHERE username=$id and $nom is not null;
-- Mettre à jour l'AESH modifié dans la base AESH
 UPDATE aesh SET aesh_name=$nom, aesh_firstname=$prenom, tel_aesh=$tel, courriel_aesh=$courriel WHERE username=$id and $nom is not null;
    -- Mettre à jour le compte modifié dans la base
 UPDATE user_info SET nom=$nom, prenom=$prenom, etab=$Etablissement, classe=$Classe, tel=$tel, courriel=$courriel, groupe=$groupe, CAS=$cas WHERE username=$id and $nom is not null
 RETURNING
   'redirect' AS component,
   'parametres.sql?tab=Profil' as link;

