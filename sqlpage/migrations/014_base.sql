CREATE TABLE biblio(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    auteur TEXT,
    titre TEXT,
    salle TEXT
    );
    
CREATE TABLE jeu(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT,
    matière TEXT,
    commentaire TEXT,
    salle TEXT
    );
    
CREATE TABLE site(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT,
    url TEXT,
    matière TEXT,
    commentaire TEXT
    );
