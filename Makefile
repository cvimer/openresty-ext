IMAGE_NAME=openresy-ext
IMAGE_PLATFORM=linux/amd64

.PHONY: build-image

build-image:
	docker build --platform=${IMAGE_PLATFORM} -t ${IMAGE_NAME} .
