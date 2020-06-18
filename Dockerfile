FROM alpine

RUN apk add --no-cache git git-gitweb lighttpd perl-cgi highlight

COPY entrypoint.sh /usr/local/bin/
COPY etc /etc

VOLUME /repo
WORKDIR /repo

ENTRYPOINT ["entrypoint.sh"]
