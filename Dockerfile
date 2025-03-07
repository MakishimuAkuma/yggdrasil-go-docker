FROM --platform=$BUILDPLATFORM alpine:latest AS builder

RUN apk update \
	&& apk upgrade --available --no-cache \
	&& apk --no-cache --virtual build-dependendencies add git go

RUN mkdir /tmp/build \
	&& cd /tmp/build \
	&& git clone https://github.com/yggdrasil-network/yggdrasil-go.git \
	&& cd yggdrasil-go \
	&& ./build \
	&& go build -o genkeys cmd/genkeys/main.go

FROM --platform=$BUILDPLATFORM alpine:latest

COPY --from=builder /tmp/build/yggdrasil-go/yggdrasil /usr/bin/yggdrasil
COPY --from=builder /tmp/build/yggdrasil-go/yggdrasilctl /usr/bin/yggdrasilctl
COPY --from=builder /tmp/build/yggdrasil-go/genkeys /usr/bin/genkeys
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

VOLUME [ "/etc/yggdrasil-network" ]

ENTRYPOINT [ "/entrypoint.sh" ]
