# Variables
DOCKER_COMPOSE = docker compose
SERVICE_NAME = template-app
WORKDIR = /workdir
APPDIR= $(WORKDIR)/app
POETRY_RUN = poetry --quiet run

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Display this help message
	@echo "\n----------------"
	@echo "${SERVICE_NAME}"
	@echo "----------------\n"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: down ## Build the Docker images for the services after ensuring services are down
	@DOCKER_BUILDKIT=1 $(DOCKER_COMPOSE) build

.PHONY: build-no-cache
build-no-cache: down ## Build the Docker images for the services bypassing the Docker cache
	@DOCKER_BUILDKIT=1 $(DOCKER_COMPOSE) build --no-cache

.PHONY: up
up: ## Start the services from the images already built in the background
	@$(DOCKER_COMPOSE) up -d

.PHONY: up-build
up-build: build up ## Build the Docker images and start the services in the background

.PHONY: stop
stop: ## Stop the services keping containers, networks and volumes
	@$(DOCKER_COMPOSE) stop

.PHONY: down
down: ## Stop the services and remove containers, networks, volumes created by up
	@$(DOCKER_COMPOSE) down -v

.PHONY: logs
logs: ## Follow logs for the services
	@$(DOCKER_COMPOSE) logs -f

.PHONY: shell
shell: ## Login into the app container
	@$(DOCKER_COMPOSE) exec $(SERVICE_NAME) bash

### Testing ###
.PHONY: test
test: lint pytest ## Run linters then the unit test suite. Ensure BUILD_MODE=development is set in the .env file otherwise this won't work

.PHONY: pytest
pytest: ## Run the unit test suite only. Ensure BUILD_MODE=development is set in the .env file otherwise this won't work
	@$(DOCKER_COMPOSE) exec $(SERVICE_NAME) $(POETRY_RUN) pytest --cov . --cov-report=xml:${WORKDIR}/coverage.xml --cov-report=html:${WORKDIR}/htmlcov --junitxml=${WORKDIR}/htmlcov/results.xml

.PHONY: lint
lint: pylint black isort ## Run all linters

.PHONY: pylint
pylint: ## Run pylint
	@$(DOCKER_COMPOSE) exec $(SERVICE_NAME) $(POETRY_RUN) pylint $(APPDIR)

.PHONY: black
black: ## Run black
	@$(DOCKER_COMPOSE) exec $(SERVICE_NAME) $(POETRY_RUN) black $(APPDIR)

.PHONY: isort
isort: ## Run isort
	@$(DOCKER_COMPOSE) exec $(SERVICE_NAME) $(POETRY_RUN) isort $(APPDIR)
