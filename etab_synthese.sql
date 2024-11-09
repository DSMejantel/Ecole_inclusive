SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, 
CASE WHEN $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties; 

SELECT 'divider' as component,
       'Liste des équipes de synthèse / coordination' as contents,
       'orange' as color,
       4 as size,
       TRUE as bold;
       
select 
    'list' as component,
    TRUE   as wrap;
select 
    structure.classe as title,
    group_concat(distinct equipe_synthese.username) as description,
    'etab_synthese_classe.sql?etab='||$id||'&classe='||structure.classe as view_link
    FROM structure JOIN equipe_synthese on structure.id=equipe_synthese.classe_id join user_info on user_info.username=equipe_synthese.username join login_session on user_info.username=login_session.username WHERE structure.etab_id=$id GROUP BY structure.classe;
