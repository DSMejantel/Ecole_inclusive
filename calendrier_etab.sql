SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET group_bouton=$group_id;

--Menu
SELECT 'dynamic' AS component, 
CASE WHEN $group_id=1
THEN sqlpage.read_file_as_text('index.json')
ELSE sqlpage.read_file_as_text('menu.json')
            END    AS properties; 
    
-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;    

select 
    'table' as component,
    'Actions' as markdown,
    TRUE as small WHERE $group_id >0;
select 
    strftime('%d/%m/%Y',horodatage) as Date,
    eleve.nom||' '||eleve.prenom||' ('||eleve.classe||')' as Élève,
    notes as description,
    '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil "Dossier de l''élève")' as Actions
    FROM intervention JOIN eleve on intervention.eleve_id=eleve.id WHERE (SELECT user_info.etab FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') and user_info.etab=eleve.etab_id) and nature='ESS' and horodatage > datetime(date('now', '-1 day')) or $group_id >1 and nature='ESS' and horodatage > datetime(date('now', '-1 day')) order by horodatage;


