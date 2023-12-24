SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'redirect' AS component,
        'notification.sql?id='||$id||'&restriction' AS link
        WHERE $group_id<'3';


update eleve set nom=
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
nom,
'Û','Û'),'Ü','Ü'),'Ý','Ý'),'à','à'),'á','á'),'â','â'),'ã','ã'),'ä','ä'),'ç','ç'),'è','è'),'é','é'),'ê','ê'),'ë','ë'),'ì','ì'),'í','í'),'î','î'),'ï','ï'),'ñ','ñ'),'ò','ò'),'ó','ó'),'ô','ô'),'õ','õ'),'ö','ö'),'ù','ù'),'ú','ú'),'û','û'),'ü','ü'),'ý','ý');
update eleve set prenom=
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
prenom,
'Û','Û'),'Ü','Ü'),'Ý','Ý'),'à','à'),'á','á'),'â','â'),'ã','ã'),'ä','ä'),'ç','ç'),'è','è'),'é','é'),'ê','ê'),'ë','ë'),'ì','ì'),'í','í'),'î','î'),'ï','ï'),'ñ','ñ'),'ò','ò'),'ó','ó'),'ô','ô'),'õ','õ'),'ö','ö'),'ù','ù'),'ú','ú'),'û','û'),'ü','ü'),'ý','ý');
update etab set nom_etab=
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
nom_etab,
'Û','Û'),'Ü','Ü'),'É','É'),'à','à'),'á','á'),'â','â'),'ã','ã'),'ä','ä'),'ç','ç'),'è','è'),'é','é'),'ê','ê'),'ë','ë'),'ì','ì'),'í','í'),'î','î'),'ï','ï'),'ñ','ñ'),'ò','ò'),'ó','ó'),'ô','ô'),'õ','õ'),'ö','ö'),'ù','ù'),'ú','ú'),'û','û'),'ü','ü'),'ý','ý');
update referent set nom_ens_ref=
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
nom_ens_ref,
'Û','Û'),'Ü','Ü'),'Ý','Ý'),'à','à'),'á','á'),'â','â'),'ã','ã'),'ä','ä'),'ç','ç'),'è','è'),'é','é'),'ê','ê'),'ë','ë'),'ì','ì'),'í','í'),'î','î'),'ï','ï'),'ñ','ñ'),'ò','ò'),'ó','ó'),'ô','ô'),'õ','õ'),'ö','ö'),'ù','ù'),'ú','ú'),'û','û'),'ü','ü'),'ý','ý')
returning 
'redirect' AS component,
'parametres.sql?tab=Comptes' as link;

-- If the insert failed, warn the user
select 'alert' as component,
    'red' as color,
    'alert-triangle' as icon,
    'Problème détecté' as title,
    'Le changement n''a pu être effectué.' as description;

