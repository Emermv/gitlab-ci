FROM golang:alpine AS builder

WORKDIR /go/src/app
COPY ./src ./

#Install dependencies
RUN go mod download

#Build
RUN go build -tags lambda.norpc -o /go/bin/app .

# FROM alpine:latest
FROM public.ecr.aws/lambda/provided:al2023

WORKDIR /app

COPY --from=builder /go/bin/app .

# CMD ["./app"]

ENTRYPOINT ["./app"]