FROM docker.io/library/golang:1.26.1-alpine AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o intel-gpu-exporter .

FROM docker.io/library/alpine:3

RUN \
    apk add --no-cache \
        tini \
        intel-gpu-tools

COPY --from=builder /build/intel-gpu-exporter /usr/local/bin/intel-gpu-exporter

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/intel-gpu-exporter"]
