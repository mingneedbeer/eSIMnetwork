FROM golang:1.22-alpine AS builder

RUN apk add --no-cache gcc musl-dev make git linux-headers

WORKDIR /app
RUN git clone https://github.com/ethereum-optimism/optimism.git .
RUN make op-node

FROM alpine:3.19

RUN apk add --no-cache ca-certificates
COPY --from=builder /app/op-node/bin/op-node /usr/local/bin/op-node

EXPOSE 8545 7300 9003

ENTRYPOINT ["op-node"]
