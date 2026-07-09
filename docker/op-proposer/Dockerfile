FROM alpine:3.19
RUN apk add --no-cache ca-certificates
COPY op-proposer /usr/local/bin/op-proposer
EXPOSE 8545
ENTRYPOINT ["op-proposer"]