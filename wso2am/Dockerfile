# ------------------------------------------------------------------------
#
# Copyright 2016 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# ------------------------------------------------------------------------

FROM ubuntu:latest
MAINTAINER dev@wso2.org

ENV DEBIAN_FRONTEND noninteractive

# Build time arguments
ARG WSO2_SERVER
ARG WSO2_SERVER_VERSION
ARG WSO2_SERVER_PROFILE
ARG WSO2_ENVIRONMENT
ARG HTTP_PUPPET_SERVER

# Carbon server information
ENV WSO2_SERVER=${WSO2_SERVER:-wso2am} \
    WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION:-1.9.1} \
    WSO2_SERVER_PROFILE=${WSO2_SERVER_PROFILE:-default} \
    WSO2_ENVIRONMENT=${WSO2_ENVIRONMENT:-dev} \
    HTTP_PUPPET_SERVER=${HTTP_PUPPET_SERVER}

COPY scripts/* /usr/local/bin/

# Export facter variables
ENV FACTER_product_name=${WSO2_SERVER} \
    FACTER_product_version=${WSO2_SERVER_VERSION} \
    FACTER_product_profile=${WSO2_SERVER_PROFILE} \
    FACTER_environment=${WSO2_ENVIRONMENT} \
    FACTER_vm_type=docker

# Execute puppet apply and clean
WORKDIR /etc/puppet
RUN addgroup wso2 \
    && adduser --system --shell /bin/bash --gecos 'WSO2User' --ingroup wso2 --disabled-login wso2user \
    && apt-get update && apt-get install -y wget puppet \
    && wget -nH -e robots=off --reject "index.html*" ${HTTP_PUPPET_SERVER}/hiera.yaml \
    && wget -rnH -e robots=off --reject "index.html*" ${HTTP_PUPPET_SERVER}/hieradata/ \
    && wget -rnH -e robots=off --reject "index.html*" ${HTTP_PUPPET_SERVER}/manifests/ \
    && wget -rnH --level=10 -e robots=off --reject "index.html*" ${HTTP_PUPPET_SERVER}/modules/wso2base/ \
    && wget -rnH --level=10 -e robots=off --reject "index.html*" ${HTTP_PUPPET_SERVER}/modules/${WSO2_SERVER}/ \
    && puppet module install puppetlabs/stdlib \
    && puppet module install 7terminals-java \
    && puppet apply -e "include ${WSO2_SERVER}" --hiera_config=/etc/puppet/hiera.yaml \
    && apt-get purge -y --auto-remove puppet wget \
    && rm -rfv /etc/puppet/* \
    && rm -rfv /var/lib/apt/lists/* \
    && chown wso2user:wso2 /usr/local/bin/* \
    && chown -R wso2user:wso2 /mnt

USER wso2user
WORKDIR /mnt

# Expose transport ports
EXPOSE 10397 8280 8243 9763 9443

ENTRYPOINT /usr/local/bin/init.sh
