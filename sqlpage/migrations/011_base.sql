CREATE TABLE structure(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    etab_id INTEGER REFERENCES etab(id),
    etab_UAI TEXT,
    classe TEXT
    );
