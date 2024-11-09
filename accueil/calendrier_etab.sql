SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SET group_bouton=$group_id;

select 
    'title'   as component,
    'Calendrier des ESS' as contents,
    TRUE as center,
    3         as level;

select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Programmer un ESS' as title,
    'index.sql?ess=1' as link,
    'square-rounded-plus' as icon,
        $group_id<3 as disabled,
    'green' as outline;

select 
    'table' as component,
    'Actions' as markdown,
    TRUE as small WHERE $group_id >0;
select 
    strftime('%d/%m/%Y',horodatage) as Date,
    eleve.nom||' '||eleve.prenom||' ('||eleve.classe||')' as Élève,
    SUBSTR(notes,0,15) as description,
    '[
    ![](./icons/briefcase.svg)
](notification.sql?id='||eleve.id||'&tab=Profil "Dossier de l''élève")' as Actions
    FROM intervention JOIN eleve on intervention.eleve_id=eleve.id WHERE (SELECT user_info.etab FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') and user_info.etab=eleve.etab_id) and nature='ESS' and horodatage > datetime(date('now', '-1 day')) or $group_id >1 and nature='ESS' and horodatage > datetime(date('now', '-1 day')) order by horodatage;


