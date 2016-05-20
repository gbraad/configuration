FROM phusion/baseimage:0.9.16
MAINTAINER Appsembler <info@appsembler.com>

ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get -y install \
    gcc \
    python-dev \
    python-apt \
    python-virtualenv \
    python-setuptools \
    libmysqlclient-dev \
    make \
    git-core && \
    easy_install pip && \
    apt-get clean

COPY . /configuration
COPY docker/helpers/server-vars.yml /tmp/

WORKDIR /configuration
RUN make requirements

WORKDIR /configuration/playbooks
COPY docker/helpers/setup /root/
RUN chmod 777 /root/setup
RUN /root/setup && apt-get clean

# Workaround: Mongo users created on the first run of the Ansible playbook are
# not persisted, probably due to runit weirdness. Creating the users after the
# container has a chance to restart fixes the issue.
COPY docker/helpers/post_setup /root/
RUN chmod 777 /root/post_setup
RUN /root/post_setup && apt-get clean

# Add configuration script to run on startup
COPY docker/helpers/configure /etc/service/configure/run
RUN chmod 777 /etc/service/configure/run

EXPOSE 80 18010 18020

CMD ["/sbin/my_init", "--enable-insecure-key"]
