FROM debian:buster

ARG DEBIAN_FRONTEND=noninteractive

# Install ruby dependencies
RUN apt update \  
    # && apt install -y dialog \  
    && apt install -y git wget curl \
    && apt install -y libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev

# Install ruby
RUN wget http://ftp.ruby-lang.org/pub/ruby/2.7/ruby-2.7.6.tar.gz \
    && tar -xzvf ruby-2.7.6.tar.gz \
    && cd ruby-2.7.6/ \
    && ./configure \
    && make install

# Install chromium and chromium driver    
RUN apt install -y chromium chromium-driver

# Install imagemagick
RUN apt install -y imagemagick

ARG USERNAME=postgres
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install postgresql 11
RUN apt install -y postgresql \
    && apt install -y libpq-dev

RUN mkdir -p /var/postgres/data \
    && mkdir -p /var/log/postgres \
    && chown postgres /var/postgres/data \
    && chown postgres /var/log/postgres

# Install Swedish and American locale
RUN sed -i 's/^# *\(sv_SE.UTF-8\)/\1/' /etc/locale.gen \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen

ARG REPO=AgileVentures
ARG BRANCH=develop

# Invalidates the cache when branch changes
ADD https://api.github.com/repos/$REPO/shf-project/git/refs/heads/$BRANCH version.json

# Clones latest version of the branch
RUN mkdir /workspaces && cd /workspaces && git clone --branch $BRANCH https://github.com/$REPO/shf-project.git shf-project

# Install bundler and gems
RUN gem install bundler:2.2.21
WORKDIR /workspaces/shf-project

USER $USERNAME
RUN sudo chown -R $(whoami):$(whoami) /workspaces

RUN gem install solargraph --user-install

RUN ([ "$(uname -m)" = "aarch64" ] \
    && bundle config set force_ruby_platform true) || exit 0

RUN bundle config set path "/home/$USERNAME/.gem"

RUN bundle install

# Install latest wkhtmltox to get around this issue: https://github.com/pallymore/wkhtmltopdf-binary-edge/issues/15
USER root
RUN apt install -y wkhtmltopdf \
    && cp /usr/bin/wkhtmltoimage /home/$USERNAME/.gem/ruby/2.7.0/gems/wkhtmltoimage-binary-0.12.5/libexec/wkhtmltoimage-amd64 \
    && cp /usr/bin/wkhtmltopdf /home/$USERNAME/.gem/ruby/2.7.0/gems/wkhtmltopdf-binary-0.12.6.5/bin/wkhtmltopdf_debian_10_i386

# Create empty db if it doesn't exist
USER $USERNAME
RUN if [ ! "$(ls -A /var/postgres/data)" ]; then LANG=sv_SE.UTF-8 /usr/lib/postgresql/11/bin/initdb /var/postgres/data; fi 
