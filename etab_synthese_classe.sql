SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Ouverture exceptionnelle de droits pour l'équipe des réunions de synthèse        
SET classe_eleve_id = (SELECT structure.id FROM structure WHERE structure.classe=$classe);
SET group_synthese = coalesce((SELECT equipe_synthese.classe_id FROM equipe_synthese LEFT join user_info on  user_info.username=equipe_synthese.username  LEFT join login_session on user_info.username=login_session.username WHERE login_session.id = sqlpage.cookie('session') and equipe_synthese.classe_id=$classe_eleve_id), 0);

SELECT 'redirect' AS component,
        'etab_synthese.sql?id='||$etab AS link
        WHERE $group_id<3 AND $group_synthese=0;

-- Insère note et info de l'historique dans la base
INSERT INTO intervention(eleve_id, horodatage,nature,notes, tracing, verrou)
SELECT 
	$id as eleve_id, 
	:horodatage as horodatage, 
	:nature as nature, 
	:notes as notes,
        coalesce(:important,0) as tracing,
        coalesce(:verrou,0) as verrou        
	WHERE $ajout=1;

UPDATE intervention SET horodatage=:horodatage,	nature=:nature, notes=:notes, tracing=coalesce(:important,0) WHERE intervention.id=$intervention_id and $edit=1;
       
--Menu
SELECT 'dynamic' AS component, 
CASE WHEN $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties;

-- intégrer les élèves en inclusion dans la liste des résultats           
SET classe_id_select = (SELECT structure.id FROM structure INNER JOIN etab on structure.etab_id=etab.id where structure.classe=$classe);

-- Bouton
select 
    'button' as component,
    'sm'     as size,
    'left' as justify,
    'pill'   as shape;
select 
    'Équipes de synthèse '||nom_etab as title,
    'messages' as icon,
    'green' as color,
    'etab_synthese.sql?id=' || etab.id as link
    FROM equipe_synthese JOIN structure on structure.id=equipe_synthese.classe_id  LEFT JOIN etab on etab.id=structure.etab_id where $group_id>2 GROUP BY etab.id; 
select 
    'Équipes de synthèse' as title,
    'messages' as icon,
    'green' as color,
    'etab_synthese.sql?id=' || user_info.etab as link
     FROM etab JOIN user_info on user_info.etab=etab.id join login_session on user_info.username=login_session.username WHERE $group_id=1 and login_session.id = sqlpage.cookie('session') GROUP BY etab.id;
             
-- Titre
SELECT 'divider' as component,
       $classe as contents,
       'orange' as color,
       4 as size,
       TRUE as bold;

select 
    'foldable' as component;
select 
    eleve.nom||' '||eleve.prenom as title,
    CASE WHEN EXISTS (SELECT eleve.id FROM intervention WHERE eleve.id = intervention.eleve_id)
    THEN group_concat(strftime('%d/%m/%Y',horodatage)||' : '||nature||' --> '||notes||'[![Editer](/icons/pencil.svg)](/intervention/intervention_edit.sql?id='||intervention.id||'&eleve='||eleve.id||'&etab='||$etab||'&classe='||$classe||')' ,
        CHAR(10) || CHAR(10) -- two line breaks between paragraphs
       ) ||'
                      [![Dossier](/icons/briefcase.svg)](notification.sql?id='||eleve.id||')[![Ajouter](/icons/circle-plus.svg)](/intervention/intervention_ajout.sql?id='||eleve.id||'&etab='||$etab||'&classe='||$classe||')' 
    ELSE '[![Dossier](/icons/briefcase.svg)](notification.sql?id='||eleve.id||')[![Ajouter](/icons/circle-plus.svg)](/intervention/intervention_ajout.sql?id='||eleve.id||'&etab='||$etab||'&classe='||$classe||')' END as description_md
  FROM eleve LEFT JOIN intervention on intervention.eleve_id=eleve.id WHERE eleve.classe=$classe and eleve.etab_id=$etab GROUP BY eleve.id  
UNION ALL
select 
    eleve.nom||' '||eleve.prenom as title,
    CASE WHEN EXISTS (SELECT eleve.id FROM intervention WHERE eleve.id = intervention.eleve_id)
    THEN group_concat(strftime('%d/%m/%Y',horodatage)||' : '||nature||' --> '||notes||'[![Editer](/icons/pencil.svg)](/intervention/intervention_edit.sql?id='||intervention.id||'&eleve='||eleve.id||'&etab='||$etab||'&classe='||$classe||')' ,
        CHAR(10) || CHAR(10) -- two line breaks between paragraphs
       ) ||'
                      [![Dossier](/icons/briefcase.svg)](notification.sql?id='||eleve.id||')[![Ajouter](/icons/circle-plus.svg)](/intervention/intervention_ajout.sql?id='||eleve.id||'&etab='||$etab||'&classe='||$classe||')' 
    ELSE '[![Dossier](/icons/briefcase.svg)](notification.sql?id='||eleve.id||')[![Ajouter](/icons/circle-plus.svg)](/intervention/intervention_ajout.sql?id='||eleve.id||'&etab='||$etab||'&classe='||$classe||')' END as description_md
    FROM eleve LEFT JOIN inclusion on eleve.id=inclusion.eleve_id LEFT JOIN intervention on intervention.eleve_id=eleve.id  WHERE inclusion.classe_id=$classe_id_select GROUP BY eleve.id ORDER BY title ASC;  


  
