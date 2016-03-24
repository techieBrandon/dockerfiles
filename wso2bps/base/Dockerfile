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
ARG CONFIG_FILE_SUFFIX
ARG JDK_ARCHIVE
ARG JAVA_INSTALL_PATH
ARG HTTP_PACK_SERVER
ARG CONFIG_FILE_SUFFIX

# Carbon server information
ENV WSO2_SERVER=${WSO2_SERVER:-wso2bps} \
    WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION:-3.5.0} \
    JDK_ARCHIVE=${JDK_ARCHIVE:-jdk-7u80-linux-x64.tar.gz} \
    JAVA_INSTALL_PATH=${JAVA_INSTALL_PATH:-/opt/java} \
    HTTP_PACK_SERVER=${HTTP_PACK_SERVER}

# Execute install script - will just download the product and jdk archives and unpack them
COPY common/install/install.sh /install.sh
RUN bash /install.sh

WORKDIR /mnt
USER wso2user

# Expose transport ports
EXPOSE 9763 9443

ENTRYPOINT /usr/local/bin/init.sh
