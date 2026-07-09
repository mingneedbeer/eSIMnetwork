FROM alpine:3.19
RUN apk add --no-cache ca-certificates
COPY op-challenger /usr/local/bin/op-challenger
EXPOSE 8545
ENTRYPOINT ["op-challenger"]