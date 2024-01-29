FROM alpine:3.14

ENV PATH="/commands:${PATH}"

RUN apk upgrade \
    && apk update \
    && apk add bash=5.1.16-r0 \
    && apk add git=2.32.7-r0 \
    && apk add grep=3.7-r0 \
    && apk add sed=4.8-r0 \
    && apk add openssh \
    && mkdir /repo \
    && git config --global --add safe.directory /repo

WORKDIR /repo

# This order of layers, to leverage "caching"
# ssh-config
COPY .no-versioned/.ssh /root

RUN eval $(ssh-agent -s) \
    && find /root/.ssh -type f ! -name "*.pub" ! -name "known_hosts*" -exec ssh-add {} \;

# repo-config
ARG EMAIL
ARG NAME

RUN git config --global user.email "${EMAIL:--}" \
    && git config --global user.name "${NAME:--}"

# commands
COPY commands /commands

RUN find /commands -type f \
    -exec sed 's|\r||g' {} > {} \; \
    -exec dos2unix {} \;
