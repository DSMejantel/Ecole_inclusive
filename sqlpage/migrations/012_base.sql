CREATE TABLE intervention(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    eleve_id INTEGER REFERENCES eleve(id),
    horodatage DATE,
    nature TEXT,
    notes TEXT,
    tracing integer DEFAULT 0
);
