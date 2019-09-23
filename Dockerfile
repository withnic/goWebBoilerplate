FROM golang:1.12.7-alpine3.10 as build

WORKDIR /go/app

COPY . .

RUN set -x && \
	apk add --no-cache git make gcc g++ \
	&& GO111MODULE=off go get -u github.com/oxequa/realize \
	&& GO111MODULE=off go get -u github.com/go-delve/delve/cmd/dlv \
	&& GO111MODULE=off go build -o /go/bin/dlv github.com/go-delve/delve/cmd/dlv \
	&& make build

FROM alpine

WORKDIR /app

COPY --from=build /go/app/app .
COPY --from=build /go/bin/dlv .

RUN set -x && \
	addgroup go \
	&& adduser -D -G go go \
	&& chown -R go:go /bin/dlv \
	&& chown -R go:go /app/app

USER go

EXPOSE 8080
CMD ["./app"]
