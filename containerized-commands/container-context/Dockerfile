FROM alpine:3.14

ARG EMAIL="-"
ARG NAME="-"
ARG COMMANDS_DIR

COPY ${COMMANDS_DIR} /commands

RUN apk upgrade \
    && apk update \
    && apk add bash=5.1.16-r0 \
    && apk add git=2.32.7-r0 \
    && apk add grep=3.7-r0 \
    && apk add sed=4.8-r0 \
    && mkdir /repo \
    && git config --local --add safe.directory /repo \
    && git config --local user.email "${EMAIL}" \
    && git config --local user.name "${NAME}"

RUN find /commands -type f \
    -exec sed 's|\r||g' {} > {} \; \
    dos2unix {} \;

WORKDIR /repo