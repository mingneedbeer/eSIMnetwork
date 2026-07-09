FROM alpine:3.19
RUN apk add --no-cache ca-certificates
COPY op-node /usr/local/bin/op-node
EXPOSE 7300 9003
ENTRYPOINT ["op-node"]