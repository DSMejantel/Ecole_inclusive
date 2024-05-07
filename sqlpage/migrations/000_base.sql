CREATE TABLE aesh(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    aesh_name TEXT,
    aesh_firstname TEXT,
    tel_aesh TEXT,
    courriel_aesh TEXT,
    quotite INTEGER,
    tps_mission INTEGER,
    tps_synthese INTEGER, tps_ULIS DECIMAL);
    
CREATE TABLE affectation(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    eleve_id INTEGER,
    dispositif_id INTEGER
);

CREATE TABLE amenag(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    eleve_id INTEGER REFERENCES eleve(id),
    info TEXT,
    amenagements TEXT,
    objectifs TEXT
);

CREATE TABLE cas_service(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    serveur TEXT,
    etat INTEGER
    );

CREATE TABLE dispositif(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dispo TEXT,
    coordo INTEGER DEFAULT 0);

CREATE TABLE edt (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aesh_id INTEGER,
    edt_url TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE eleve(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT,
    prenom TEXT,
    naissance DATE,
    etab_id INTEGER,
    classe TEXT,
    referent_id INTEGER,
    comm_eleve TEXT, 
    modification TIMESTAMP, editeur TEXT, niveau TEXT);

CREATE TABLE etab(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT,
    nom_etab TEXT,
    Lon DECIMAL,
    Lat DECIMAL,
    description TEXT
    );

CREATE TABLE examen(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT,
    mesure TEXT
    );

CREATE TABLE examen_eleve (
	id	INTEGER PRIMARY KEY,
	eleve_id	INTEGER,
	code_id	INTEGER
    );

CREATE TABLE fiche (
	id	INTEGER PRIMARY KEY,
	titre	TEXT,
	contenu	TEXT,
	auteur	INTEGER,
	fiche_url	TEXT NOT NULL,
	created_at	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	tag	TEXT
    );

CREATE TABLE image (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    eleve_id INTEGER,
    image_url TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE login_session (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL REFERENCES user_info(username),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_cas TEXT, token TEXT);

CREATE TABLE modalite(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT
    );

CREATE TABLE niveaux(
    niv TEXT PRIMARY KEY
    );

CREATE TABLE notif(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    notification_id INTEGER,
    modalite_id INTEGER, 
    eleve_id INTEGER
    );

CREATE TABLE notification(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    eleve_id INTEGER REFERENCES eleve(id),
    origine TEXT,
    datedeb DATE,
    datefin DATE,
    modalite TEXT,
    acces TEXT, 
    Departement TEXT
    );
    
CREATE TABLE referent(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    nom_ens_ref TEXT,
    prenom_ens_ref TEXT,
    tel_ens_ref TEXT,
    email TEXT
);

CREATE TABLE suivi(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    eleve_id INTEGER REFERENCES eleve(id),
    aesh_id INTEGER REFERENCES aesh(id),
    temps DECIMAL,
    mut INTEGER DEFAULT 1,
    ind INTEGER DEFAULT 0, 
    mission TEXT
    );
    
CREATE TABLE user_info (
	username	TEXT PRIMARY KEY,
	password_hash	TEXT,
	nom	TEXT,
	prenom	TEXT,
	tel	TEXT,
	courriel	TEXT,
	groupe	INTEGER,
	connexion	TIMESTAMP DEFAULT Null,
	activation	TEXT DEFAULT Null,
	etab	INTEGER DEFAULT Null, 
	classe INTEGER DEFAULT Null, 
	CAS TEXT
);
