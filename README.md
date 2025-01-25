* Runterladen der Tabelle mit den Resultaten von Google Drive als CSV
* Umbenennen der runtergeladenen Tabelle

```
cp Abstimmung\ Förderprojekte\ 2025\ \(Antworten\)\ -\ Formularantworten\ 1.csv abstimmung_gv_2025.csv
```

* Löschen der ersten (leeren) Zeile in der CSV Tabelle falls vorhanden
* Speichern der Excel Mitgliederliste als CSV mit Komma als Trennung und Hochkommata für Textfelder
* Umbenennen der CSV Liste

```
mv "QGIS Usergruppe Schweiz Mitgliederliste.csv" mitgliederliste.csv
```

* Setzen der Verbindung zur Datenbank als Umgebungsvariablen

```
export DBNAME=your_db_name
export HOST=localhost
export PORT=5432
export USER=your_db_user
```

* Kopiere die Tabelle Mitgliederliste in die Datenbank, überschreibe bestehende Daten

```
ogr2ogr -f PostgreSQL -oo HEADERS=YES -lco OVERWRITE=YES -lco SCHEMA=gv2025 PG:"dbname=$DBNAME host=$HOST port=$PORT user=$USER" mitgliederliste.csv mitgliederliste
```

* Kopiere die Tabelle Abstimmung in die Datenbank, überschreibe bestehende Daten

```
ogr2ogr -f PostgreSQL -oo HEADERS=YES -lco OVERWRITE=YES -lco SCHEMA=gv2025 PG:"dbname=$DBNAME host=$HOST port=$PORT user=$USER" abstimmung_gv_2025.csv abstimmung_gv_2025
```

* Anlegen der Datenbank Views:

```
psql -h $HOST -p $PORT -f create_views.sql $DBNAME $USER
```

* Anzeigen Resultat

```
psql -h $HOST -p $PORT -c "SELECT * FROM gv2025.resultate_nach_projekt" $DBNAME $USER
```

* Export nach CSV

```
psql --csv -h $HOST -p $PORT -c "SELECT * FROM gv2025.resultate_nach_projekt" $DBNAME $USER > resultate.csv
```
