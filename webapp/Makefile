
db: nerds-and-threads.sqlite3
nerds-and-threads.sqlite3:
	ruby ../setup_db.rb

up: db
	rackup

run: up

clean:
	rm nerds-and-threads.sqlite3
