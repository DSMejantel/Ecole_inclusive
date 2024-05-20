SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<'3';

SET annee_en_cours=(SELECT annee FROM annee WHERE active=1)

DELETE FROM parcours WHERE annee_id=$annee_en_cours;

INSERT INTO parcours (annee_id, eleve_id, etab_id, niveau, classe, referent_id, aesh_id, dispositif_id)
SELECT $annee_en_cours, eleve.id, eleve.etab_id, eleve.niveau, eleve.classe, SUBSTR(prenom_ens_ref, 1, 1) ||'. '||nom_ens_ref , SUBSTR(aesh_firstname, 1, 1) ||'. '||aesh_name,
group_concat(DISTINCT dispositif.dispo)
FROM eleve LEFT JOIN referent on referent.id=eleve.referent_id LEFT JOIN suivi on suivi.eleve_id=eleve.id LEFT JOIN aesh on aesh.id=suivi.aesh_id LEFT JOIN affectation on affectation.eleve_id=eleve.id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id WHERE eleve.etab_id>0 GROUP BY eleve.id
returning 
'redirect' AS component,
'parametres.sql?tab=Comptes' as link;

-- If the insert failed, warn the user
select 'alert' as component,
    'red' as color,
    'alert-triangle' as icon,
    'Problème détecté' as title,
    'La mise à jour n''a pu être effectuée.' as description;

