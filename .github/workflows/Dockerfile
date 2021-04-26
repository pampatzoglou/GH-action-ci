FROM ubuntu:focal

ARG KUBECTL_VERSION="v1.20.4"
ARG HELM_VERSION="v3.5.2"
ARG HELM_DIFF_VERSION="v3.1.1"
ARG HELMFILE_VERSION="v0.138.4"
ARG YQ_VERSION="3.3.2"
ARG KIND_VERSION="0.10.0"

ADD commands/* /usr/local/bin/  

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
    apt-transport-https ca-certificates curl wget gnupg git software-properties-common tzdata bash lsb-release runc socat && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 && \
    apt-add-repository https://cli.github.com/packages && \
    apt-get update && apt-get install --no-install-recommends --yes gh docker-ce docker-ce-cli containerd.io && \
    wget -O /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    wget -O helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar zxfv helm.tar.gz && rm helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -fr linux-amd64 && \
    helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} && \
    wget -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64 && \
    wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 && \
    wget -O /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 && \
    chmod a+x /usr/local/bin/*

ENTRYPOINT ["/bin/bash"]