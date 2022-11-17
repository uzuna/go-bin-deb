FROM alpine

COPY build/amd64/go-bin-deb /bin/

RUN apk add --update make