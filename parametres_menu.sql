select 
    'big_number'          as component;


select 
    'Outils' as title,
    'orange'    as color,
    json_array(
    json_object(
    'label', 'Référents',
    'link', '/referent.sql'),
    json_object(
    'label', 'Type de notifications',
    'link', '/modalite.sql'),
    json_object(
    'label', 'Aménagements d''examen',
    'link', '/examen.sql'),
    json_object(
    'label', 'Type de  dispositifs',
    'link', '/dispositif.sql'),
    json_object(
    'label', 'Établissements',
    'link', '/etab_ajout.sql'),
    json_object(
    'label', 'Niveaux',
    'link', '/niveaux.sql'),
    json_object(
    'label', 'Classes',
    'link', '/structure.sql'),
    json_object(
    'label', 'Années scolaires',
    'link', '/annees.sql')
    )  as dropdown_item;
