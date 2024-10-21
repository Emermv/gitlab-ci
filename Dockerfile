FROM golang:alpine AS builder

WORKDIR /go/src/app
COPY ./src ./

RUN go build -o /go/bin/app .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /go/bin/app .

CMD ["./app"]