# syntax=docker/dockerfile:latest
FROM --platform=${TARGETPLATFORM} golang:1.23 AS builder

# multi-arch
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH

WORKDIR /go/src/github.com/eagleusb/cql-proxy

COPY . .

RUN go mod tidy -v

RUN GOOS=linux GOARCH=${TARGETARCH} CGO_ENABLED=0 \
  go build -ldflags="-s -w" -o /go/bin/cql-proxy .

RUN go test -short -v ./...

FROM --platform=${TARGETPLATFORM} alpine:3

RUN apk add --no-cache \
  ca-certificates

# Copy in the binary
COPY --from=builder --chmod=755 /go/bin/cql-proxy .

HEALTHCHECK NONE
ENTRYPOINT ["/cql-proxy"]
CMD []
EXPOSE 9042
