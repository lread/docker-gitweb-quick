IMAGE_NAME = leeread/gitweb-quick

VERSION_MAJOR = 1
VERSION_MINOR = 0
VERSION_PATCH := $(shell git rev-list --count HEAD)
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

TAG = $(IMAGE_NAME):$(VERSION)
TAG_LATEST = $(IMAGE_NAME):latest

# GitWeb default highlight style is not great, specify a different one.
# Note that when picking a style, a light one should be chosen as highlight
# styling does not affect background color at all.
HIGHLIGHT_STYLE = base16/ia-light

TEST_PORT = 3000
PROJECT_DIR := $(shell pwd)
TEST_REPO_DIR = $(PROJECT_DIR)

define status_line
  @printf "\033[42m \033[30;46m %-100s \033[42m \033[0m\n" "$(1)"
endef

.PHONY: clean highlight-filetypes-config gitweb-config gitweb-highlight-css image build test interact git-tag release

clean:
	$(call status_line, deleting all build work)
	rm -rf target

target:
	mkdir -p target

# Grab highlight config from a docker alpine image
target/filetypes.conf: target
	$(call status_line,Fetching highlight filetypes config)
	docker run -i -t -v $(realpath $(PROJECT_DIR))/target:/target alpine \
         /bin/sh -c "apk add highlight; cp /etc/highlight/filetypes.conf /target"

highlight-filetypes-config: target/filetypes.conf

# Convert highlight config to gitweb syntax
target/image-files/etc/gitweb/gitweb_config.perl: highlight-filetypes-config
	$(call status_line,Transcribing highlight config to gitweb config)
	clojure -Sdeps '{:deps {instaparse {:mvn/version "1.4.10"}} :paths ["script"]}' \
          -m gen-gitweb-highlight-config target/filetypes.conf target/gitweb_highlight_config.perl
	mkdir -p target/image-files/etc/gitweb
	cat image-files/etc/gitweb/gitweb_config.perl \
      target/gitweb_highlight_config.perl > target/image-files/etc/gitweb/gitweb_config.perl

gitweb-config: target/image-files/etc/gitweb/gitweb_config.perl

# Grab a better syntax highlight css - because the default was disappointing
target/image-files/usr/share/gitweb/static/highlight.css: target
	$(call status_line,Generating highlight style stylesheet: $(HIGHLIGHT_STYLE))
	mkdir -p target/image-files/usr/share/gitweb/static
	docker run -i -t -v $(realpath $(PROJECT_DIR))/target:/target alpine \
         /bin/sh -c "apk add highlight; touch dummy.txt; highlight -i dummy.txt -o dummy.out --style=$(HIGHLIGHT_STYLE); cp highlight.css /target/image-files/usr/share/gitweb/static"

gitweb-highlight-css: target/image-files/usr/share/gitweb/static/highlight.css

# Build our docker image
image: gitweb-highlight-css gitweb-config
	$(call status_line,Building docker image with tag $(TAG))
	docker build --no-cache --tag $(TAG) .
	docker tag $(TAG) $(TAG_LATEST)

# Try out built image interactively
# Override TEST_REPO_DIR via: make test TEST_REPO_DIR=/your/path/to/repo
test:
	$(call status_line,Firing up interactive test for image $(TAG))
	$(call status_line,- against repo in $(realpath $(TEST_REPO_DIR)))
	$(call status_line,- view in your browser at http://localhost:$(TEST_PORT)/?p=.git)
	docker run --rm -i -t -p $(TEST_PORT):1234 -v $(realpath $(TEST_REPO_DIR)):/repo:ro $(TAG)

# Interact with built image by logging into shell
interact:
	$(call status_line,Firing up shell session for image $(TAG))
	$(call status_line,- against repo in $(realpath $(TEST_REPO_DIR)))
	docker run --rm -i -t -p $(TEST_PORT):1234 -v $(realpath $(TEST_REPO_DIR)):/repo:ro --entrypoint /bin/ash $(TAG)

# CI server tags after successful build
git-tag:
	$(call status_line,Creating and pushing git vesion tag $(VERSION))
	git tag v$(VERSION)
	git push origin v$(VERSION)

# You, or CI server will have successfully logged in before invoking release
release:
	$(call status_line,Pushing image $(TAG) to docker hub)
	docker push $(TAG)
	docker push $(TAG_LATEST)
