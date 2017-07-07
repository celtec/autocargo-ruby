# Version: 0.0.1
FROM ubuntu:xenial

MAINTAINER Celtec Tecnologia e Serviços "@celtec_tech"

ENV AUTOCARGO_USER autocargo
ENV AUTOCARGO_GROUP app

# Create autocargo user in Ubuntu
RUN groupadd $AUTOCARGO_GROUP
RUN useradd -r $AUTOCARGO_USER -g $AUTOCARGO_GROUP
RUN mkdir -p /home/$AUTOCARGO_USER
RUN chown $AUTOCARGO_USER:$AUTOCARGO_GROUP -R /home/$AUTOCARGO_USER

# Install dependencies
RUN apt-get update
RUN apt-get install -y build-essential curl git
RUN apt-get install -y python3-dev python-dev openssl libssl-dev libcurl4-openssl-dev libreadline6-dev
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
WORKDIR /home/$AUTOCARGO_USER/
USER $AUTOCARGO_USER
RUN git clone https://github.com/sstephenson/rbenv.git /home/$AUTOCARGO_USER/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /home/$AUTOCARGO_USER/.rbenv/plugins/ruby-build

#USER root
#RUN .rbenv/plugins/ruby-build/install.sh
#RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

# TODO: Export PATH as $AUTOCARGO_USER
# export PATH="$HOME/.rbenv/bin:$PATH"
USER $AUTOCARGO_USER
ENV PATH /home/$AUTOCARGO_USER/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# Install ruby 2.1.5
ENV CONFIGURE_OPTS --disable-install-doc
ENV RUBY_BUILD_CACHE_PATH /home/$AUTOCARGO_USER/.rbenv/cache/
RUN mkdir -p $RUBY_BUILD_CACHE_PATH
COPY packages/ruby/ruby-2.1.5.tar.bz2 $RUBY_BUILD_CACHE_PATH
RUN rbenv install 2.1.5
RUN rbenv global 2.1.5
RUN rbenv rehash

# Create apps directories
USER root
RUN mkdir -p /opt/apps
RUN chown $AUTOCARGO_USER:$AUTOCARGO_GROUP /opt/apps

# Update RubyGems
USER $AUTOCARGO_USER
echo 'gem: --no-rdoc --no-ri' >> /.gemrc
gem update --system

## Install Bundler
RUN gem install bundler
