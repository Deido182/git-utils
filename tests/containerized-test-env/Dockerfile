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
ENV SSH_DIR="/project/containerized-commands/container-context/ssh"

RUN rm -r "${SSH_DIR}"; \
    mkdir "${SSH_DIR}" \
    && touch "${SSH_DIR}/private_key.1" \
    && chmod 600 "${SSH_DIR}/private_key.1" \
    && touch "${SSH_DIR}/known_hosts" 

WORKDIR /project
