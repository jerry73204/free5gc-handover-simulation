.PHONY: up down clean logs help

# Start all services with docker-compose
up:
	docker-compose up -d

# Stop all services
down:
	docker-compose down

# Clean Docker images
clean:
	docker-compose down --rmi all --volumes --remove-orphans 2>/dev/null
	docker rmi $(FREE5GC_IMAGE):$(TAG) $(UERANSIM_IMAGE):$(TAG) 2>/dev/null
	docker image prune -f

# Show logs
logs:
	docker-compose logs -f

# Show help
help:
	@echo "Available targets:"
	@echo "  up             - Build and start all services with docker-compose"
	@echo "  down           - Stop all services"
	@echo "  logs           - Show logs from all services"
	@echo "  clean          - Remove Docker images and cleanup"
	@echo "  help           - Show this help message"

