FROM golang:1.22-alpine AS builder

RUN apk add --no-cache gcc musl-dev make git linux-headers

WORKDIR /app
RUN git clone https://github.com/ethereum-optimism/op-geth.git .
RUN make geth

FROM alpine:3.19

RUN apk add --no-cache ca-certificates
COPY --from=builder /app/build/bin/geth /usr/local/bin/geth

EXPOSE 8545 8546 30303 30303/udp

ENTRYPOINT ["geth"]
