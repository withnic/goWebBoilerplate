FROM golang:1.12.7-alpine3.10 as build

WORKDIR /go/app

COPY . .

RUN set -x && \
	apk add --no-cache git make gcc g++ \
	&& GO111MODULE=off go get github.com/oxequa/realize \
	&& make build

FROM alpine

WORKDIR /app

COPY --from=build /go/app/app .

RUN set -x && \
	addgroup go \
	&& adduser -D -G go go \
	&& chown -R go:go /app/app

USER go

EXPOSE 8080
CMD ["./app"]
