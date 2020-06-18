IMAGE_NAME = leeread/gitweb-quick

VERSION_MAJOR = 1
VERSION_MINOR = 0
VERSION_PATCH := $(shell git rev-list --count HEAD)
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

TAG = $(IMAGE_NAME):$(VERSION)
TAG_LATEST = $(IMAGE_NAME):latest

TEST_PORT = 3000
TEST_REPO_DIR := $(shell pwd)

.PHONY: image

image:
	docker build --no-cache --tag $(TAG) .
	docker tag $(TAG) $(TAG_LATEST)

# Try out a build interactively
# Override TEST_REPO_DIR via: make test TEST_REPO_DIR=/your/path/to/repo
test:
	docker run --rm -i -t -p $(TEST_PORT):1234 -v $(realpath $(TEST_REPO_DIR)):/repo:ro $(TAG)

# CI server tags after successful build
git-tag:
	git tag v$(VERSION)
	git push origin v$(VERSION)

# You, or CI server will have successfully logged in before invoking release
release:
	docker push $(TAG)
	docker push $(TAG_LATEST)
