select 
    'big_number'          as component;
select 
    'Classe : '||coalesce($classe_select,'aucune') as title,
    'orange'    as color,
    json_group_array(json_object(
    'label', classe,
    'link', 'etab_classes.sql?id='||$id||'&classe_select='||classe))  as dropdown_item
    FROM (Select classe, classe from eleve where etab_id=$id  GROUP BY classe UNION ALL SELECT '- Aucune' as label, 'Aucune' as link ORDER BY classe);
select 
    'Dispositifs : '||coalesce((SELECT dispo from dispositif WHERE id=$dispo_select),'aucun') as title,
    'orange'    as color,
    json_group_array(json_object(
    'label', dispo,
    'link', 'etab_dispositifs.sql?id='||$id||'&dispo_select='||id))  as dropdown_item
    FROM (Select dispo, id from dispositif UNION ALL SELECT '- Aucun' as label, 'Aucun' as link  ORDER BY dispo ASC);
select 
    'Notifications et suivis' as title,
    'green'    as color,
    json_array(
    json_object(
    'label', 'AESH',
    'link', '/etab_aesh.sql?id='||$id),
    json_object(
    'label', 'Notifications',
    'link', '/etab_notif.sql?id='||$id),
    json_object(
    'label', 'Suivis',
    'link', '/etab_suivi.sql?id='||$id),
        json_object(
    'label', 'Examens',
    'link', '/etab_examen.sql?id='||$id)) as dropdown_item WHERE $group_id>1;
select 
    'Notifications et suivis' as title,
    'green'    as color,
    json_array(
    json_object(
    'label', 'Notifications',
    'link', '/etab_notif.sql?id='||$id),
    json_object(
    'label', 'Suivis',
    'link', '/etab_suivi.sql?id='||$id),
        json_object(
    'label', 'Examens',
    'link', '/etab_examen.sql?id='||$id)) as dropdown_item WHERE $group_id<2;

select 
    'Outils' as title,
    'teal'    as color,
    json_array(
    json_object(
    'label', 'Statistiques',
    'link', '/etab_stats.sql?id='||$id),
    json_object(
    'label', 'Carte',
    'link', '/etab_carte.sql?id='||$id),
        json_object(
    'label', 'Trombinoscope',
    'link', '/etab_trombi.sql?id='||$id))  as dropdown_item;
