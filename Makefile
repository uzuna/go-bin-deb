PACKAGE_NAME:=$(shell cat deb.json | jq -r '.name')
VERSION:=$(shell cat VERSION)
ARCH?=amd64


setup:
	apt install upx

build:
	mkdir -p build/${ARCH}
	GOARCH=${ARCH} go build -a -gcflags=all="-l -B" -ldflags="-w -s" -o build/${ARCH}/${PACKAGE_NAME}
	upx --best --ultra-brute helloworld build/${ARCH}/${PACKAGE_NAME}

deb:
	rm -rf pkg-build
	go-bin-deb generate -arch ${ARCH} -version ${VERSION}

clean:
	rm -rf build

.PHONY: build-container
build-container:
	docker build . -t ghcr.io/${OWNER}/${PACKAGE_NAME}

.PHONY: push-container
push-container:
	docker push ghcr.io/${OWNER}/${PACKAGE_NAME}:latest