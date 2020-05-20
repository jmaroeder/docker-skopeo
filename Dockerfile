FROM golang:1.12-alpine AS builder
RUN apk add --no-cache \
    git \
    make \
    gcc \
    musl-dev \
    btrfs-progs-dev \
    lvm2-dev \
    gpgme-dev \
    glib-dev || apk update && apk upgrade

WORKDIR /go/src/github.com/containers/skopeo

ARG VERSION=v1.0.0
RUN git clone --branch ${VERSION} --depth 1 https://github.com/containers/skopeo.git .
RUN make binary-local-static DISABLE_CGO=1


FROM alpine:3.7
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/containers/skopeo/skopeo /usr/local/bin/skopeo
COPY --from=builder /go/src/github.com/containers/skopeo/default-policy.json /etc/containers/policy.json
ENTRYPOINT ["/usr/local/bin/skopeo"]
CMD ["--help"]
