# syntax=docker/dockerfile:latest
FROM --platform=${TARGETPLATFORM} golang:1.23 AS builder

# multi-arch
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH

# Disable cgo to remove gcc dependency
ENV CGO_ENABLED=0

WORKDIR /go/src/cql-proxy

# Grab the dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy in source
COPY . ./

# Build and install binary
RUN go install github.com/datastax/cql-proxy

# Run unit tests
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
