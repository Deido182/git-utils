FROM docker:20.10.24

RUN apk upgrade \
    && apk update \
    && apk add bash>=5.1.16-r0 \
    && apk add git>=2.32.7-r0 \
    && apk add grep>=3.7-r0 \
    && apk add sed>=4.8-r0 \
    && mkdir /project \
    && git config --global init.defaultBranch master

COPY / /project

ENV PATH="/project/containerized-commands:$PATH"

WORKDIR /project
