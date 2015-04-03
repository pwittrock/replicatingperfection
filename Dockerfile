FROM phusion/baseimage
MAINTAINER Phillip Wittrock < philwittrock [at] gmail {dot} com>

# Additional Repose
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y mongodb

RUN apt-get install -y git

RUN apt-get install -y npm
RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN apt-get install -y python-software-properties software-properties-common
RUN apt-get install -y unzip
RUN apt-get install -y wget

# Java
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get install -y oracle-java8-installer oracle-java8-set-default
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Node
RUN npm install -g bower
RUN npm install -g coffee-script

ENV LEIN_ROOT true
RUN wget -q -O /usr/bin/lein \
  https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
  && chmod +x /usr/bin/lein \
  && /usr/bin/lein

RUN apt-get install libzmq3-dev -y

RUN curl -s https://storage.googleapis.com/signals-agents/logging/install-google-fluentd-debian-wheezy.sh | sh

# Setup user account
RUN useradd -ms /bin/bash jinteki
USER jinteki
ENV HOME /home/jinteki
WORKDIR $HOME

RUN mkdir $HOME/netrunner
WORKDIR $HOME/netrunner
RUN lein
ADD netrunner/package.json $HOME/netrunner/package.json
RUN npm install
ADD netrunner/bower.json $HOME/netrunner/bower.json
RUN echo "yes" | bower install
ADD netrunner/project.clj $HOME/netrunner/project.clj
ADD netrunner/profiles.clj $HOME/netrunner/profiles.clj
RUN lein cljsbuild once
RUN npm install zmq

USER root
COPY netrunner/data $HOME/netrunner/data
COPY netrunner/resources $HOME/netrunner/resources
RUN chown -R jinteki:jinteki $HOME/

USER jinteki
WORKDIR $HOME/netrunner/data
RUN coffee fetch.coffee
WORKDIR $HOME/netrunner

USER root
COPY netrunner/ $HOME/netrunner/
USER root
RUN chown -R jinteki:jinteki $HOME/

USER jinteki
WORKDIR $HOME/netrunner/data
RUN coffee fetch.coffee
WORKDIR $HOME/netrunner
RUN bower install
RUN lein cljsbuild once
RUN lein uberjar
RUN mkdir $HOME/data

USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EXPOSE 1042
EXPOSE 1043
ENTRYPOINT ["/sbin/my_init", "--"]
