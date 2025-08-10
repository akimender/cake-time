IMAGE_NAME = frontend
TAG = latest
CONTAINER_NAME = frontend_container
PORT = 5173

help:
	@echo "make run-server   - Restart and run server"
	@echo "make build        - Build the Docker image"
	@echo "make run          - Run the container"
	@echo "make stop         - Stop the container"
	@echo "make logs         - View container logs"
	@echo "make shell        - Enter the container shell"
	@echo "make clean        - Remove image and container"

run-server:
	make stop
	make run

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

run:
	docker run --name $(CONTAINER_NAME) -p $(PORT):$(PORT) $(IMAGE_NAME):$(TAG)

stop:
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

logs:
	docker logs -f $(CONTAINER_NAME)

shell:
	docker exec -it $(CONTAINER_NAME) sh

clean: stop
	docker rmi $(IMAGE_NAME):$(TAG) || true
