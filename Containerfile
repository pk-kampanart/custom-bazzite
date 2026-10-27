ARG BASE_IMAGE

# Build context stage; pattern from ublue-os/bazzite-dx and image-template.
FROM scratch AS ctx

COPY build_files /build_files
COPY system_files /system_files

FROM ${BASE_IMAGE}

ARG IMAGE_NAME
ARG IMAGE_VENDOR=pk-kampanart

# /var/roothome is created first like ublue-os/bazzite-dx (/root -> var/roothome).
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=cache,dst=/var/cache \
    mkdir -p /var/roothome && \
    IMAGE_NAME="${IMAGE_NAME}" IMAGE_VENDOR="${IMAGE_VENDOR}" \
    /ctx/build_files/build.sh

RUN bootc container lint
