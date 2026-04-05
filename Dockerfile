FROM docker.io/library/golang:1.26.1-alpine AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o intel-gpu-exporter .

FROM docker.io/library/debian:trixie-slim

ENV \
    DEBCONF_NONINTERACTIVE_SEEN="true" \
    DEBIAN_FRONTEND="noninteractive"

RUN \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        tini \
        intel-gpu-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/intel-gpu-exporter /usr/local/bin/intel-gpu-exporter

ENTRYPOINT ["/usr/bin/tini", "-s", "--", "/usr/local/bin/intel-gpu-exporter"]
