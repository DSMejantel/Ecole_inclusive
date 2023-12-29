DROP VIEW IF EXISTS stats01;
CREATE VIEW stats01 AS
SELECT eleve.etab_id AS etab,
    affectation.dispositif_id AS Num_dispositif,
    eleve.classe AS classe,
    dispositif.dispo as Nom_dispositif,
    coalesce(count(dispositif.dispo),0) as Nombre    
FROM affectation CROSS JOIN eleve on affectation.eleve_id=eleve.id LEFT JOIN dispositif on dispositif.id=affectation.dispositif_id 
Group by eleve.classe, dispositif.dispo
Order by eleve.classe;
