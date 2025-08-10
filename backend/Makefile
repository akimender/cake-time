# Variables
DOCKER_IMAGE = cake-time-backend
DOCKER_CONTAINER = cake-time-backend-container
DOCKER_TAG = latest
PORT = 8000

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# Dependency management
pip-compile: ## Compile requirements.txt from requirements.in
	@echo "Installing pip-tools..."
	pip install pip-tools
	pip-compile requirements.in

install-deps: ## Install Python dependencies locally
	pip install -r requirements.in

# Docker commands
build: ## Build Docker image
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

run: ## Run Docker container
	docker run -d --name $(DOCKER_CONTAINER) -p $(PORT):8000 $(DOCKER_IMAGE):$(DOCKER_TAG)

stop: ## Stop Docker container
	docker stop $(DOCKER_CONTAINER) || true
	docker rm $(DOCKER_CONTAINER) || true

restart: stop run ## Restart Docker container

clean: ## Remove Docker image and containers
	docker stop $(DOCKER_CONTAINER) || true
	docker rm $(DOCKER_CONTAINER) || true
	docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG) || true

logs: ## Show Docker container logs
	docker logs -f $(DOCKER_CONTAINER)

shell: ## Access Docker container shell
	docker exec -it $(DOCKER_CONTAINER) /bin/bash

# Django management commands
migrate: ## Run Django migrations
	docker exec $(DOCKER_CONTAINER) python manage.py migrate

makemigrations: ## Create Django migrations
	docker exec $(DOCKER_CONTAINER) python manage.py makemigrations

createsuperuser: ## Create Django superuser
	docker exec -it $(DOCKER_CONTAINER) python manage.py createsuperuser

collectstatic: ## Collect static files
	docker exec $(DOCKER_CONTAINER) python manage.py collectstatic --noinput

# Development commands
dev: build run ## Build and run in development mode
	@echo "Development environment ready!"
	@echo "Backend running on: http://localhost:$(PORT)"
	@echo "API docs: http://localhost:$(PORT)/api/"

test: ## Run tests
	docker exec $(DOCKER_CONTAINER) python manage.py test

# Database commands
dbshell: ## Access Django database shell
	docker exec -it $(DOCKER_CONTAINER) python manage.py dbshell

reset-db: ## Reset database (WARNING: This will delete all data)
	@echo "WARNING: This will delete all database data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker exec $(DOCKER_CONTAINER) python manage.py flush --noinput; \
		echo "Database reset complete!"; \
	else \
		echo "Database reset cancelled."; \
	fi

# Utility commands
status: ## Show container status
	@echo "Container status:"
	docker ps -a | grep $(DOCKER_CONTAINER) || echo "Container not found"

health: ## Check application health
	@echo "Checking application health..."
	curl -f http://localhost:$(PORT)/health/ || echo "Health check failed"

# Quick setup
setup: pip-compile install-deps build run migrate ## Complete setup: install deps, build, run, and migrate
	@echo "Setup complete!"
	@echo "Backend running on: http://localhost:$(PORT)"
