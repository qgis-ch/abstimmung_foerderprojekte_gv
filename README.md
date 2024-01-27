Umbenennen des runtergeladenen Tabelle

`cp Abstimmung\ Förderprojekte\ 2024\ \(Antworten\)\ -\ Formularantworten\ 1.csv abstimmung_gv_2024.csv`

* Speichern der Excel Mitgliederliste als CSV mit Komma als Trennung und Hochkommata für Textfelder
* Umbenennund der CSV Liste

`mv "QGIS Usergruppe Schweiz Mitgliederliste.csv" mitgliederliste.csv`

* Setzen der Verbindung zur Datenbank als Umgebungsvariablen

`export $DBNAME=your_db_name
export $HOST=localhost
export $PORT=5432
export $USER=your_db_user`

* Kopiere die Tabelle Mitgliederliste in die Datenbank, überschreibe bestehende Daten

`ogr2ogr -f PostgreSQL -oo HEADERS=YES -lco OVERWRITE=YES -lco SCHEMA=gv2024 PG:"dbname=$DBNAME host=$HOST port=$PORT user=$USER" mitgliederliste.csv mitgliederliste`

* Kopiere die Tabelle Abstimmung in die Datenbank, überschreibe bestehende Daten

`ogr2ogr -f PostgreSQL -oo HEADERS=YES -lco OVERWRITE=YES -lco SCHEMA=gv2024 PG:"dbname=$DBNAME host=$HOST port=$PORT user=$USER" abstimmung_gv_2024.csv abstimmung_gv_2024`