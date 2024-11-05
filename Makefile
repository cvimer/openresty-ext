IMAGE_NAME=openresy-ext

.PHONY: build-image

build-image:
	docker build -t ${IMAGE_NAME} .