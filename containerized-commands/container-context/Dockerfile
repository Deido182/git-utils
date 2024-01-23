FROM alpine:3.14

ARG EMAIL="-"
ARG NAME="-"
ARG COMMANDS_DIR

COPY ${COMMANDS_DIR}/git-* /bin
COPY ${COMMANDS_DIR}/libs /bin/libs

# Remove possible special characters (e.g., \r)
RUN find ${COMMANDS_DIR} -type f -exec sed $'s|[^[:print:]\t]||g' {} \;

RUN apk upgrade \
    && apk update \
    && apk add 'bash=3.2.57' \
    && apk add 'git=2.25.1' \
    && apk add 'grep=3.4' \
    && apk add 'sed=4.7' \
    && mkdir /tmp/git-utils \
    && mkdir /repo \
    && git config --global --add safe.directory /repo \
    && git config --global user.email "${EMAIL}" \
    && git config --global user.name "${NAME}"

WORKDIR /repo