FROM --platform=$BUILDPLATFORM docker.io/golang:latest AS builder

ARG TARGETPLATFORM

ENV CGO_ENABLED=0

WORKDIR /tmp/build

COPY ./yggdrasil-go .

RUN case "$TARGETPLATFORM" in \
        "linux/386") GOOS=linux GOARCH=386 ./build && go build -o genkeys cmd/genkeys/main.go ;; \
        "linux/s390x") GOOS=linux GOARCH=s390x ./build && go build -o genkeys cmd/genkeys/main.go ;; \
        "linux/amd64") GOOS=linux GOARCH=amd64 ./build && go build -o genkeys cmd/genkeys/main.go ;; \
        "linux/arm/v6") GOOS=linux GOARCH=arm GOARM=6 ./build && go build -o genkeys cmd/genkeys/main.go ;; \
        "linux/arm/v7") GOOS=linux GOARCH=arm GOARM=7 ./build && go build -o genkeys cmd/genkeys/main.go ;; \
        "linux/arm64") GOOS=linux GOARCH=arm64 ./build && go build -o genkeys cmd/genkeys/main.go ;; \
        "linux/ppc64le") GOOS=linux GOARCH=ppc64le ./build && go build -o genkeys cmd/genkeys/main.go ;; \
        "linux/riscv64") GOOS=linux GOARCH=riscv64 ./build && go build -o genkeys cmd/genkeys/main.go ;; \
    esac

FROM docker.io/alpine:latest

COPY --from=builder /tmp/build/yggdrasil /usr/bin/yggdrasil
COPY --from=builder /tmp/build/yggdrasilctl /usr/bin/yggdrasilctl
COPY --from=builder /tmp/build/genkeys /usr/bin/genkeys
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

VOLUME [ "/etc/yggdrasil-network" ]

ENTRYPOINT [ "/entrypoint.sh" ]
