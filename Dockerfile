FROM alpine

LABEL org.opencontainers.image.source = "https://github.com/uzuna/go-bin-deb"

COPY build/amd64/go-bin-deb /bin/

RUN apk add --update make fakeroot dpkg
