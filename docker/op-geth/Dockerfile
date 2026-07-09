FROM alpine:3.19
RUN apk add --no-cache ca-certificates
COPY geth /usr/local/bin/geth
EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]