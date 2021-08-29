FROM golang:1.17-alpine AS base
RUN mkdir app
WORKDIR /app
COPY src/ .
ENV CGO_ENABLED=0
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download


FROM base AS build
WORKDIR /app
COPY --from=base /app .
RUN --mount=target=./app/ \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -o /out/go-rest-api .


FROM alpine:3.14 AS bin
COPY --from=build /out/go-rest-api /
COPY --from=build /app/ ./app


FROM bin
CMD ["/go-rest-api"]
