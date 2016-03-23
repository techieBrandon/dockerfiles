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

# Carbon server information
ENV WSO2_SERVER=${WSO2_SERVER:-wso2am} \
    WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION:-1.9.1} \
    WSO2_ENVIRONMENT=${WSO2_ENVIRONMENT:-dev} \
    CONFIG_FILE_SUFFIX=${CONFIG_FILE_SUFFIX:-simple} \
    JDK_ARCHIVE=${JDK_ARCHIVE:-jdk-7u80-linux-x64.tar.gz}

COPY common/ pack/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip  /mnt/

# Execute configuration script - a file with name <CONFIG_FILE_SUFFIX>-configurer will be picked
RUN addgroup wso2 \
    && adduser --system --shell /bin/bash --gecos 'WSO2User' --ingroup wso2 --disabled-login wso2user \
    && apt-get install zip unzip \
    && unzip -q /mnt/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip -d /mnt \
    && mkdir -p /opt/java \
    && tar -xf /mnt/jdk/${JDK_ARCHIVE} -C /opt/java --strip-components=1 \
    && cp /mnt/scripts/* /usr/local/bin/ \
    && rm /mnt/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip \
    && rm /mnt/jdk/${JDK_ARCHIVE} \
    && chown wso2user:wso2 /usr/local/bin/* \
    && chown -R wso2user:wso2 /mnt

USER wso2user
WORKDIR /mnt

# Expose transport ports
EXPOSE 10397 8280 8243 9763 9443

ENTRYPOINT /usr/local/bin/init.sh
