FROM ubuntu:18.04
MAINTAINER Abdulla Abdurakhmanov <abdulla.abd.m@gmail.com>

RUN apt-get update && apt-get install -y curl locales vim mercurial rubygems ruby-dev git git-lfs wget \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common 

# Fonts (for converting SVGs mostly)
RUN apt-get update && apt-get install -y libfontconfig sed \
	fonts-roboto* fonts-cantarell fonts-lato* fonts-ubuntu* \	
	lmodern ttf-aenigma ttf-georgewilliams ttf-bitstream-vera ttf-sjfonts tv-fonts

RUN DEBIAN_FRONTEND=noninteractive apt-cache search ^fonts- | sed 's/^\(fonts-[^ ]*\).*$/\1/' | grep -v "fonts-mathematica" | xargs apt-get install --install-suggests --fix-missing -y -q

# Docker repository for Ubuntu
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Locales
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Java / Amazon Corretto
RUN apt-get update && apt-get install java-common

RUN curl https://apt.corretto.aws/corretto.key | apt-key add -
RUN add-apt-repository 'deb https://apt.corretto.aws stable main'
RUN apt-get update && apt-get install -y java-1.8.0-amazon-corretto-jdk

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-amazon-corretto

# Langs
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8

# SBT
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \ 
    apt-get update && \
    apt-get install sbt && \
    sbt info

# NodeJS PPA
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs gcc g++ make

# npm
RUN npm install npm -g

# Vulcanize
RUN npm install -g vulcanize
RUN npm install -g polymer-bundler

# Workbox
RUN npm install workbox-cli --global

# Bower
RUN npm install -g bower
RUN npm install -g yarn

# Old and npm SASS
RUN gem install sass
RUN mkdir -p /usr/lib/node_modules/node-sass/vendor && npm install -g node-sass --unsafe-perm --force

# Image converting tools
RUN npm install -g svgexport --unsafe-perm --force
RUN apt install -y webp

# FUSE
RUN apt-get install -y fuse kmod openssl sed augeas-lenses dh-python libaugeas0 libffi-dev libmpdec2 libpython3-stdlib libssl-dev python3-minimal python3-pkg-resources python3-virtualenv python3.4 python3.4-minimal virtualenv zlib1g-dev

# Haskell
ENV PATH="/root/.local/bin:${PATH}"
RUN curl -sSL https://get.haskellstack.org/ | sh

# Flyway
RUN wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/5.2.4/flyway-commandline-5.2.4-linux-x64.tar.gz | tar xvz && ln -s `pwd`/flyway-5.2.4/flyway /usr/local/bin && rm -f `pwd`/flyway-5.2.4/drivers/postgresql-*.jar && curl -o `pwd`/flyway-5.2.4/drivers/postgresql-42.2.6.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.6/postgresql-42.2.6.jar

# Google Cloud Sdk
RUN CLOUD_SDK_REPO="cloud-sdk-$(grep VERSION_CODENAME /etc/os-release | cut -d '=' -f 2)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    GCSFUSE_REPO="gcsfuse-`lsb_release -c -s`" && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install -y google-cloud-sdk gcsfuse kubectl

WORKDIR /opt/build

COPY cloud-env-common.sh /root/.local/bin/
COPY cloud-env-init.sh /root/.local/bin/
COPY google-cloud-init.sh /root/.local/bin/

COPY entrypoint.sh /opt

COPY utils/*.sh /root/.local/bin/

ENTRYPOINT ["/opt/entrypoint.sh"]
