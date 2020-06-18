FROM alpine

LABEL description="Expose a local git repository to your browser via gitweb"

RUN apk add --no-cache \
  git \
  git-gitweb \
  highlight \
  lighttpd \
  perl-cgi

COPY entrypoint.sh /usr/local/bin/
COPY etc /etc

VOLUME /repo
WORKDIR /repo

ENTRYPOINT ["entrypoint.sh"]
