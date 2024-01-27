BEGIN;

-- Setze die Bedingung, dass keine falschen Kategorien ausgefüllt werden können
ALTER TABLE gv2024.mitgliederliste DROP CONSTRAINT kategorie_pruefung;
ALTER TABLE gv2024.mitgliederliste ADD CONSTRAINT kategorie_pruefung CHECK (kategorie IN ('A', 'B', 'C', 'D', 'E'));

CREATE OR REPLACE VIEW gv2024.gewichtung_kategorie AS (
    SELECT
        *
    FROM (
        VALUES
            ( 1 , 'A', 3 ),        
            ( 2 , 'B', 2 ),        
            ( 3 , 'C', 1 ),
            ( 4 , 'D', 1 ),
            ( 5 , 'E', 0 )
    )
    AS t (id, kategorie, gewicht)
);

CREATE OR REPLACE VIEW gv2024.projekte AS (
    SELECT
        *
    FROM (
        VALUES
            ( 1 , 'Projekt 1', 3000 ),        
            ( 2 , 'Projekt 1', 2222 ),        
            ( 3 , 'Projekt 1', 1333 ),
            ( 4 , 'Projekt 1', 1222 ),
            ( 5 , 'Projekt 1', 199 )
    )
    AS t (projekt_id, beschreibung, preis_in_chf)
);

DROP VIEW IF EXISTS gv2024.resultate_formatiert CASCADE;

CREATE VIEW gv2024.resultate_formatiert AS (
    SELECT
        ogc_fid,
        to_timestamp(zeitstempel,'DD.MM.YYYY HH24:MI:SS') AS zeitstempel,
        e_mail_adresse,
        "ausgewählte förderprojekte",
        split_part(split_part(ag."ausgewählte förderprojekte",',',1),':',1)::integer AS projekt_wahl_1,
        split_part(split_part(ag."ausgewählte förderprojekte",',',2),':',1)::integer AS projekt_wahl_2,
        split_part(split_part(ag."ausgewählte förderprojekte",',',3),':',1)::integer AS projekt_wahl_3
    FROM
        gv2024.abstimmung_gv_2024 ag
);

DROP VIEW IF EXISTS gv2024.resultate_gewichtet;

CREATE VIEW gv2024.resultate_gewichtet AS (
    SELECT
        rf.ogc_fid,
        rf.zeitstempel,
        rf.e_mail_adresse,
        ml."name",
        ml.vorname,
        rf.projekt_wahl_1,
        rf.projekt_wahl_2,
        rf.projekt_wahl_3,
        ml.kategorie,
        gk.gewicht AS kategorie_gewicht,
        CASE WHEN rf.projekt_wahl_1 = 1 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 1 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 1 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_1_stimme,
        CASE WHEN rf.projekt_wahl_1 = 2 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 2 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 2 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_2_stimme,
        CASE WHEN rf.projekt_wahl_1 = 3 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 3 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 3 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_3_stimme
    FROM
        gv2024.resultate_formatiert rf 
    JOIN
        gv2024.mitgliederliste ml
        ON
            rf.e_mail_adresse = ml.email
    JOIN
        gv2024.gewichtung_kategorie gk
        ON
            gk.kategorie = ml.kategorie
);

DROP VIEW IF EXISTS gv2024.resultate_nach_projekt;

CREATE VIEW gv2024.resultate_nach_projekt AS (
    WITH zusammenfassung AS (
        SELECT
            1::integer AS projekt,
            SUM(projekt_1_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            2::integer AS projekt,
            SUM(projekt_2_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            3::integer AS projekt,
            SUM(projekt_3_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
    )
    SELECT
        p.projekt_id,
        p.beschreibung,
        z.anzahl_stimmen,
        p.preis_in_chf
    FROM
        zusammenfassung z
    JOIN
        gv2024.projekte p
        ON
            z.projekt = p.projekt_id
    ORDER BY
        anzahl_stimmen
        DESC
);


END;