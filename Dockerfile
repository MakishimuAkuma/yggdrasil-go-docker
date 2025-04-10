FROM docker.io/golang:alpine AS builder

ENV CGO_ENABLED=0

WORKDIR /tmp/build

ADD https://github.com/yggdrasil-network/yggdrasil-go.git#v0.5.12 .

RUN ./build && go build -o genkeys cmd/genkeys/main.go

FROM docker.io/alpine:latest

COPY --from=builder /tmp/build/yggdrasil /usr/bin/yggdrasil
COPY --from=builder /tmp/build/yggdrasilctl /usr/bin/yggdrasilctl
COPY --from=builder /tmp/build/genkeys /usr/bin/genkeys
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

VOLUME [ "/etc/yggdrasil-network" ]

ENTRYPOINT [ "/entrypoint.sh" ]
