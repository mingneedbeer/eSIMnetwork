FROM alpine:3.19
RUN apk add --no-cache ca-certificates
COPY op-batcher /usr/local/bin/op-batcher
EXPOSE 8545
ENTRYPOINT ["op-batcher"]