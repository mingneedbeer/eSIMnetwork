FROM golang:1.22-alpine AS builder

RUN apk add --no-cache gcc musl-dev make git linux-headers

WORKDIR /app
RUN git clone https://github.com/ethereum-optimism/optimism.git .
RUN make op-proposer

FROM alpine:3.19

RUN apk add --no-cache ca-certificates
COPY --from=builder /app/op-proposer/bin/op-proposer /usr/local/bin/op-proposer

EXPOSE 8545

ENTRYPOINT ["op-proposer"]
