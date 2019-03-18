FROM golang:1.12-alpine as builder

RUN apk add --update bash git upx && rm -rf /var/cache/apk/*


RUN mkdir -p $(go env GOPATH)/src/github.com/mmatczuk/go-http-tunnel && \
    cd $(go env GOPATH)/src/github.com/mmatczuk/go-http-tunnel && \
    git init && \
    git remote add origin https://github.com/mmatczuk/go-http-tunnel.git && \
    git fetch --depth 1 origin 9116a9ab487d245d30dbcc5f9d30bd4de8a08c42 && \
    git checkout FETCH_HEAD

RUN cd $(go env GOPATH)/src/github.com/mmatczuk/go-http-tunnel && \
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /go/bin/tunneld ./cmd/tunneld && \
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /go/bin/tunnel  ./cmd/tunnel

RUN upx -5 /go/bin/tunnel
RUN upx -5 /go/bin/tunneld

FROM alpine:3.9

EXPOSE 80 443 5223

COPY --from=builder /go/bin/tunneld /go/bin/tunneld /usr/local/bin/
