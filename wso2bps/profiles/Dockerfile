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
ARG CONFIG_FILE_SUFFIX

# Carbon server information
ENV WSO2_SERVER=${WSO2_SERVER:-wso2bps} \
    WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION:-3.5.0} \
    WSO2_SERVER_PROFILE=${WSO2_SERVER_PROFILE:-default} \
    WSO2_ENVIRONMENT=${WSO2_ENVIRONMENT:-dev} \
    CONFIG_FILE_SUFFIX=${CONFIG_FILE_SUFFIX:-puppetbased} \
    HTTP_PUPPET_SERVER=${HTTP_PUPPET_SERVER}

COPY scripts/* /usr/local/bin/

# Export facter variables
ENV FACTER_product_name=${WSO2_SERVER} \
    FACTER_product_version=${WSO2_SERVER_VERSION} \
    FACTER_product_profile=${WSO2_SERVER_PROFILE} \
    FACTER_environment=${WSO2_ENVIRONMENT} \
    FACTER_vm_type=docker

# Execute configuration script - a file with name <CONFIG_FILE_SUFFIX>-configure.sh will be picked
COPY configure/${CONFIG_FILE_SUFFIX}-configure.sh /${CONFIG_FILE_SUFFIX}-configure.sh
RUN bash /${CONFIG_FILE_SUFFIX}-configure.sh

USER wso2user
WORKDIR /mnt

# Expose transport ports
EXPOSE 9763 9443

ENTRYPOINT /usr/local/bin/init.sh
