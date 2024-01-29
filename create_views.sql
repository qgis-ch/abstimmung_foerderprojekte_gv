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

DROP VIEW IF EXISTS gv2024.projekte CASCADE;

CREATE OR REPLACE VIEW gv2024.projekte AS (
    SELECT
        *
    FROM (
        VALUES
            ( 1 , 'Linear Referencing Symbology and Labeling', 9200 ),
            ( 2 , 'Annotations: Text on Line/Bezier Curves', 2880 ),
            ( 3 , 'Quantized Mesh Format Provider (primarily for terrain)', 8840 ),
            ( 4 , 'Profile Plot basierend auf swissalti3D / swisstopo API', 5760 ),
            ( 5 , 'File Upload for Processing', 2880 ),
            ( 6 , 'Unzip / Zip for Processing', 2880 ),
            ( 7 , 'Store Python expression functions to project', 2160 ),
            ( 8 , 'Store processing (Python) script algorithms to project', 2160 ),
            ( 9 , 'Trusted projects / folders', 4320 ),
            ( 10 , 'QField: Skizzenfunktion', 5760 ),
            ( 11 , 'Stacked Diagrams', 8640 ),
            ( 12 , 'Maintenance SwissLocator', 4320 )
    )
    AS t (projekt_id, beschreibung, preis_in_chf)
);

DROP VIEW IF EXISTS gv2024.resultate_formatiert CASCADE;

CREATE VIEW gv2024.resultate_formatiert AS (
    SELECT
        ogc_fid,
        to_timestamp(zeitstempel,'DD.MM.YYYY HH24:MI:SS') AS zeitstempel,
        e_mail_adresse,
        "wahl förderprojekte _ vote projets de soutien" AS wahl_vote,
        split_part(split_part(ag."wahl förderprojekte _ vote projets de soutien",',',1),':',1)::integer AS projekt_wahl_1,
        split_part(split_part(ag."wahl förderprojekte _ vote projets de soutien",',',2),':',1)::integer AS projekt_wahl_2,
        split_part(split_part(ag."wahl förderprojekte _ vote projets de soutien",',',3),':',1)::integer AS projekt_wahl_3
    FROM
        gv2024.abstimmung_gv_2024 ag
);

DROP VIEW IF EXISTS gv2024.resultate_gewichtet CASCADE;

CREATE VIEW gv2024.resultate_gewichtet AS (
    WITH neuste_stimmabgabe AS (
        SELECT
            MAX(rf.zeitstempel) AS zeitstempel,
            rf.e_mail_adresse
        FROM
            gv2024.resultate_formatiert rf
        GROUP BY
            rf.e_mail_adresse
    )
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
        END AS projekt_3_stimme,
        CASE WHEN rf.projekt_wahl_1 = 4 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 4 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 4 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_4_stimme,
        CASE WHEN rf.projekt_wahl_1 = 5 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 5 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 5 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_5_stimme,
        CASE WHEN rf.projekt_wahl_1 = 6 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 6 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 6 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_6_stimme,
        CASE WHEN rf.projekt_wahl_1 = 7 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 7 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 7 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_7_stimme,
        CASE WHEN rf.projekt_wahl_1 = 8 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 8 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 8 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_8_stimme,
        CASE WHEN rf.projekt_wahl_1 = 9 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 9 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 9 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_9_stimme,
        CASE WHEN rf.projekt_wahl_1 = 10 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 10 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 10 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_10_stimme,
        CASE WHEN rf.projekt_wahl_1 = 11 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 11 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 11 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_11_stimme,
        CASE WHEN rf.projekt_wahl_1 = 12 THEN gk.gewicht
            WHEN rf.projekt_wahl_2 = 12 THEN gk.gewicht
            WHEN rf.projekt_wahl_3 = 12 THEN gk.gewicht
            ELSE 0::integer
        END AS projekt_12_stimme
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
    JOIN
        neuste_stimmabgabe ns
        ON
            rf.zeitstempel = ns.zeitstempel AND rf.e_mail_adresse = ns.e_mail_adresse
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
        UNION
            SELECT
            4::integer AS projekt,
            SUM(projekt_4_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            5::integer AS projekt,
            SUM(projekt_5_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            6::integer AS projekt,
            SUM(projekt_6_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            7::integer AS projekt,
            SUM(projekt_7_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            8::integer AS projekt,
            SUM(projekt_8_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            9::integer AS projekt,
            SUM(projekt_9_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            10::integer AS projekt,
            SUM(projekt_10_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            11::integer AS projekt,
            SUM(projekt_11_stimme) AS anzahl_stimmen
        FROM
            gv2024.resultate_gewichtet rg
        UNION
            SELECT
            12::integer AS projekt,
            SUM(projekt_12_stimme) AS anzahl_stimmen
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

-- Zeige ungültige Stimmabgaben
SELECT
    * 
FROM 
    gv2024.resultate_formatiert rf 
WHERE
    rf.e_mail_adresse NOT IN (
        SELECT email FROM gv2024.mitgliederliste m
    )
;


END;