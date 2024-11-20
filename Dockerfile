FROM alpine:latest AS builder

RUN apk update \
	&& apk upgrade --available --no-cache \
	&& apk --no-cache --virtual build-dependendencies add git go

RUN mkdir /tmp/build \
	&& cd /tmp/build \
	&& git clone https://github.com/yggdrasil-network/yggdrasil-go.git \
	&& cd yggdrasil-go \
	&& ./build \
	&& go build -o genkeys cmd/genkeys/main.go

FROM alpine:latest

RUN mkdir -p /etc/yggdrasil-network /opt/yggdrasil-network \
	&& chown -R nobody: /etc/yggdrasil-network \
 	&& chown -R nobody: /opt/yggdrasil-network
	
WORKDIR /opt/yggdrasil-network

COPY --from=builder --chown=nobody:nogroup /tmp/build/yggdrasil-go/yggdrasil ./yggdrasil
COPY --from=builder --chown=nobody:nogroup /tmp/build/yggdrasil-go/yggdrasilctl ./yggdrasilctl
COPY --from=builder --chown=nobody:nogroup /tmp/build/yggdrasil-go/genkeys ./genkeys
COPY entrypoint.sh ./entrypoint.sh

RUN chmod +x ./entrypoint.sh

VOLUME [ "/etc/yggdrasil-network" ]

ENTRYPOINT [ "./entrypoint.sh" ]
