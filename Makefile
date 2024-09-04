

# DB
db: nerds-and-threads.sqlite3

nerds-and-threads.sqlite3:
	ruby setup_db.rb
	echo DB is setup now..
init:
#this is just for Ricc at work
#git config --global --add safe.bareRepository all
	bundle install

# play with IRB from README
run-interactive: db
	ruby main.rb

# More direct : execute once to see if it works E2E
run-test-e2e: db
	ruby test-e2e.rb

test-e2e: run-test-e2e
