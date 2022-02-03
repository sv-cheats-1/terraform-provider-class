FROM golang:1.15-alpine3.12 AS build

RUN apk --no-cache add \
    bash \
    gcc \
    musl-dev \
    openssl
RUN mkdir -p /go/src/github.com/myuser/todo-terraform-provider-class
WORKDIR /go/src/github.com/myuser/todo-terraform-provider-class
# This copies in more than we need, but since we are
# creating a second image it is not really a big deal.
ADD . /go/src/github.com/myuser/todo-terraform-provider-class
RUN go build -mod=vendor --ldflags '-linkmode external -extldflags "-static"' ./cmd/todo-list-server

FROM alpine:3.12 AS deploy

RUN apk --no-cache add curl

WORKDIR /
COPY --from=build /go/src/github.com/myuser/todo-terraform-provider-class/todo-list-server /

HEALTHCHECK --interval=15s --timeout=3s \
  CMD curl -f http://127.0.0.1/?limit=1 || exit 1

ENTRYPOINT ["/todo-list-server"] 
CMD ["--scheme=http", "--host=0.0.0.0", "--port=80"]
