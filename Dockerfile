FROM ghcr.io/jguer/yay-builder:latest
LABEL maintainer="Jguer,docker@jguer.space"

ARG VERSION
ARG PREFIX
ARG ARCH

WORKDIR /app
COPY . .
RUN ls -la Makefile
RUN go mod download
RUN pacman -Syu --overwrite=* --noconfirm
RUN make build VERSION=${VERSION} PREFIX=${PREFIX} ARCH=${ARCH}
RUN make -n build VERSION=${VERSION} PREFIX=${PREFIX} ARCH=${ARCH}
RUN make build VERSION=${VERSION} PREFIX=${PREFIX} ARCH=${ARCH}
