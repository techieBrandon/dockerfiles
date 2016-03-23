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

# Carbon server information
ENV WSO2_SERVER=${WSO2_SERVER:-wso2am} \
    WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION:-1.9.1} \
    JDK_ARCHIVE=${JDK_ARCHIVE:-jdk-7u80-linux-x64.tar.gz} \
    JAVA_INSTALL_PATH=${JAVA_INSTALL_PATH:-/opt/java} \
    HTTP_PACK_SERVER=${HTTP_PACK_SERVER}

WORKDIR /mnt
RUN addgroup wso2 \
    && adduser --system --shell /bin/bash --gecos 'WSO2User' --ingroup wso2 --disabled-login wso2user \
    && apt-get install -y unzip wget \
    && mkdir -p /mnt/jdk \
    && mkdir -p /mnt/pack \
    && wget -nH -e robots=off --reject "index.html*" -nv ${HTTP_PACK_SERVER}/jdk/${JDK_ARCHIVE} -P jdk \
    && wget -nH -e robots=off --reject "index.html*" -nv ${HTTP_PACK_SERVER}/pack/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip -P pack \
    && wget -rnH --level=10 -e robots=off --reject "index.html*" --no-parent -nv ${HTTP_PACK_SERVER}/scripts/ \
    && echo "unpacking ${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip to /mnt" \
    && unzip -q /mnt/pack/${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip -d /mnt \
    && mkdir -p /opt/java \
    && echo "unpacking ${JDK_ARCHIVE} to /opt/java" \
    && tar -xf /mnt/jdk/${JDK_ARCHIVE} -C ${JAVA_INSTALL_PATH} --strip-components=1 \
    && chmod -R 0755 /mnt/scripts \
    && cp /mnt/scripts/* /usr/local/bin/ \
    && rm -rf /mnt/pack \
    && rm -rf /mnt/jdk \
    && rm -rf /mnt/scripts \
    && apt-get purge -y --auto-remove wget unzip \
    && rm -rfv /var/lib/apt/lists/* \
    && chown wso2user:wso2 /usr/local/bin/* \
    && chown -R wso2user:wso2 /mnt

USER wso2user

# Expose transport ports
EXPOSE 10397 8280 8243 9763 9443

ENTRYPOINT /usr/local/bin/init.sh
