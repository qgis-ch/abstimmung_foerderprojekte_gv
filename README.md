* Runterladen der Tabelle mit den Resultaten von Google Drive als CSV
* Umbenennen der runtergeladenen Tabelle

```
cp Abstimmung\ Förderprojekte\ 2024\ \(Antworten\)\ -\ Formularantworten\ 1.csv abstimmung_gv_2024.csv
```

* Löschen der ersten (leeren) Zeile in der CSV Tabelle
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
ogr2ogr -f PostgreSQL -oo HEADERS=YES -lco OVERWRITE=YES -lco SCHEMA=gv2024 PG:"dbname=$DBNAME host=$HOST port=$PORT user=$USER" mitgliederliste.csv mitgliederliste
```

* Kopiere die Tabelle Abstimmung in die Datenbank, überschreibe bestehende Daten

```
ogr2ogr -f PostgreSQL -oo HEADERS=YES -lco OVERWRITE=YES -lco SCHEMA=gv2024 PG:"dbname=$DBNAME host=$HOST port=$PORT user=$USER" abstimmung_gv_2024.csv abstimmung_gv_2024
```

* Anlegen der Datenbank Views:

```
psql -h $HOST -p $PORT -f create_views.sql $DBNAME $USER
```

* Anzeigen Resultat

```
psql -h $HOST -p $PORT -c "SELECT * FROM gv2024.resultate_nach_projekt" $DBNAME $USER
```

* Export nach CSV

```
psql --csv -h $HOST -p $PORT -c "SELECT * FROM gv2024.resultate_nach_projekt" $DBNAME $USER > resultate.csv
```
