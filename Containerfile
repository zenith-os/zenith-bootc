FROM alpine:3.19 AS verify

RUN apk add --no-cache curl tar zstd

COPY ./build/zenithos-rootfs.tar.zst .

RUN mkdir /rootfs && \
    tar -C /rootfs --extract --file zenithos-rootfs.tar.zst

FROM scratch AS root

LABEL org.opencontainers.image.title="Zenith OS Bootable Image"
LABEL org.opencontainers.image.description="Official bootable container image for Zenith OS"
LABEL org.opencontainers.image.authors="Soroush Alinia <soroushalinia.wm@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/zenith-os/"
LABEL org.opencontainers.image.documentation="https://zenith-os.github.io/docs/docker"
LABEL org.opencontainers.image.licenses="MIT"

COPY --from=verify /rootfs/ /

ENV LANG=C.UTF-8
CMD ["/usr/bin/bash"]
