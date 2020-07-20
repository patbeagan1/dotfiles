sqlite3 db .dump | gzip -c > "db.`date +%s`.dmp.gz"
sqlite3 db ".backup db.`date +%s`.bak"
