IMAGE_NAME = leeread/gitweb-quick

VERSION_MAJOR = 1
VERSION_MINOR = 0
VERSION_PATCH := $(shell git rev-list --count HEAD)
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

TAG = $(IMAGE_NAME):$(VERSION)

TEST_PORT = 3000
TEST_REPO_DIR := $(shell pwd)

.PHONY: image

image:
	docker build --no-cache --tag $(TAG) .
	docker tag $(TAG) $(IMAGE_NAME):latest

# try out a build interactively
# override TEST_REPO_DIR via: make test TEST_REPO_DIR=/your/path/to/repo
test:
	docker run --rm -i -t -p $(TEST_PORT):1234 -v $(realpath $(TEST_REPO_DIR)):/repo:ro $(TAG)
