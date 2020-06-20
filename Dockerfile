FROM alpine

LABEL description="Expose a local git repository to your browser via gitweb"

RUN apk add --no-cache \
  git \
  git-gitweb \
  highlight \
  lighttpd \
  perl-cgi

COPY image-files /
COPY target/image-files /

VOLUME /repo
WORKDIR /repo

ENTRYPOINT ["entrypoint.sh"]
