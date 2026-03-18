PB_BINARY := ./pocketbase
MIGRATIONS_DIR := ../pb_migrations
HOOKS_DIR := ../pb_hooks

.PHONY: serve migrate seed clean

## Start PocketBase server met migrations en hooks
serve:
	$(PB_BINARY) serve --migrationsDir=$(MIGRATIONS_DIR) --hooksDir=$(HOOKS_DIR)

## Run alleen migrations
migrate:
	$(PB_BINARY) migrate up --migrationsDir=$(MIGRATIONS_DIR)

## Reset database en seed opnieuw
seed:
	rm -f pb_data/data.db
	$(PB_BINARY) migrate up --migrationsDir=$(MIGRATIONS_DIR)
	@echo "Database opnieuw geseeded."

## Verwijder database
clean:
	rm -rf pb_data
	@echo "Database verwijderd."
