COMPOSE := docker compose --env-file .env -f infrastructure/docker/compose.yml

.DEFAULT_GOAL := help
.PHONY: help env config up down reset ps logs psql mysql

help: ## Show available commands
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  %-8s %s\n", $$1, $$2}'

env: ## Create .env from .env.example if it does not exist
	@test -f .env && echo ".env already exists" || (cp .env.example .env && echo "Created .env — review the values")

config: ## Validate the Compose file
	$(COMPOSE) config --quiet && echo "compose.yml is valid"

up: ## Start PostgreSQL and MySQL and wait until healthy
	$(COMPOSE) up -d --wait

down: ## Stop containers (data volumes are kept)
	$(COMPOSE) down

reset: ## Stop containers and DELETE data volumes (re-runs init scripts on next up)
	$(COMPOSE) down -v

ps: ## Show container status and health
	$(COMPOSE) ps

logs: ## Follow logs (make logs s=postgres to filter)
	$(COMPOSE) logs -f $(s)

psql: ## Open psql inside the PostgreSQL container
	$(COMPOSE) exec postgres sh -c 'psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"'

mysql: ## Open the mysql client inside the MySQL container
	$(COMPOSE) exec mysql sh -c 'MYSQL_PWD="$$MYSQL_PASSWORD" mysql -u "$$MYSQL_USER" "$$MYSQL_DATABASE"'
