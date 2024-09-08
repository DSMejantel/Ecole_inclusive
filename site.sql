SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Insertion dans la base
 INSERT INTO site(nom, url, matière, commentaire) 
    SELECT :nom, :url, :matière, :commentaire WHERE :nom IS NOT NULL;
    
  UPDATE site 
  SET  nom=:nom_edit, url=:url, matière=:matière, commentaire=:commentaire WHERE id=$id and $update=1;

--Menu
SELECT 'dynamic' AS component,
sqlpage.read_file_as_text('index.json')  AS properties where $group_id=1;

SELECT 'dynamic' AS component,
sqlpage.read_file_as_text('menu.json')  AS properties where $group_id>1;
  
-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' 
    as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;  

-- Liste et ajout
select 
    'card' as component,
     CASE WHEN $group_id>1 THEN 2 ELSE 1 END as columns;
select 
    '/sites/liste.sql?_sqlpage_embed' as embed;
select 
    '/sites/form.sql?_sqlpage_embed' as embed where $group_id>1;
