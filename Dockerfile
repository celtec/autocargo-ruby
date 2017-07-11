# Version: 0.0.1
FROM ubuntu:xenial
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER Celtec Tecnologia e Serviços "@celtec_tech"

ENV AUTOCARGO_USER autocargo
ENV AUTOCARGO_GROUP app
ENV AUTOCARGO_USER_HOME /home/$AUTOCARGO_USER

# Create autocargo user in Ubuntu
RUN groupadd $AUTOCARGO_GROUP
RUN useradd -r $AUTOCARGO_USER -g $AUTOCARGO_GROUP && \
  echo "$AUTOCARGO_USER:$AUTOCARGO_GROUP" | chpasswd && \
  adduser $AUTOCARGO_USER $AUTOCARGO_GROUP && \
  adduser $AUTOCARGO_USER sudo
RUN mkdir -p $AUTOCARGO_USER_HOME
RUN chown $AUTOCARGO_USER:$AUTOCARGO_GROUP -R $AUTOCARGO_USER_HOME

# Install dependencies
RUN apt-get update
RUN apt-get install -y build-essential curl git
RUN apt-get install -y vim python3-dev python-dev openssl libssl-dev libcurl4-openssl-dev libreadline6-dev libpq5 libpq-dev libsqlite3-dev
RUN apt-get clean

# Build node-v0.4.9
ADD packages/lib/node-v0.4.9.tar.gz /usr/local/src/
WORKDIR /usr/local/src/node-v0.4.9/
RUN ["./configure"]
RUN ["make"]
RUN ["make", "install"]

# Build coffee-script-1.1.1
ADD packages/lib/coffee-script-v1.1.1.tar.gz /usr/local/src/
WORKDIR /usr/local/src/coffee-script-v1.1.1/
RUN ["bin/cake", "install"]

# Build wkhtmltopdf-0.11.0
ADD packages/lib/wkhtmltopdf-v0.11.0.tar.gz /usr/local/src/
WORKDIR /usr/local/src/
RUN ["mv", "wkhtmltopdf-i386", "/usr/local/bin/wkhtmltopdf"]

# Install rbenv and ruby-build
WORKDIR $AUTOCARGO_USER_HOME
USER $AUTOCARGO_USER
ENV AUTOCARGO_RBENV_PATH $AUTOCARGO_USER_HOME/.rbenv
RUN git clone https://github.com/sstephenson/rbenv.git $AUTOCARGO_RBENV_PATH
RUN git clone https://github.com/sstephenson/ruby-build.git $AUTOCARGO_RBENV_PATH/plugins/ruby-build

USER $AUTOCARGO_USER
ENV PATH $AUTOCARGO_RBENV_PATH/bin:$AUTOCARGO_RBENV_PATH/shims:$PATH
COPY files/.bashrc $AUTOCARGO_USER_HOME/.bashrc

# Install ruby 2.1.5
ENV CONFIGURE_OPTS --disable-install-doc
ENV RUBY_BUILD_CACHE_PATH $AUTOCARGO_RBENV_PATH/cache/
RUN mkdir -p $RUBY_BUILD_CACHE_PATH
COPY packages/ruby/ruby-2.1.5.tar.bz2 $RUBY_BUILD_CACHE_PATH
ENV RUBYGEMS_VERSION 2.1.5
RUN rbenv install $RUBYGEMS_VERSION
RUN rbenv global $RUBYGEMS_VERSION
RUN rbenv rehash

# Update RubyGems
USER $AUTOCARGO_USER
COPY files/.gemrc $AUTOCARGO_USER_HOME/.gemrc
ENV AUTOCARGO_RBENV_SHIMS_PATH $AUTOCARGO_RBENV_PATH/shims
RUN gem update --system $RUBYGEMS_VERSION

## Install Bundler
#RUN echo $(`ls -lha ./`)
RUN gem install bundler

# Create apps directories
USER root
RUN mkdir -p /opt/apps
RUN chown $AUTOCARGO_USER:$AUTOCARGO_GROUP /opt/apps

USER $AUTOCARGO_USER
