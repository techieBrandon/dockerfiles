#!/bin/bash
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
EVENT_PROCESSOR_XML_FILE_PATH=${CARBON_HOME}/repository/conf/event-processor.xml

if [[ ${PLATFORM} -eq 'mesos' ]]; then
  echo "platform=${PLATFORM}, not replacing hostnames of eventSync, management and presentation"
else
  # replace eventSync/hostName
  sed -i "/<eventSync>/,/<\/eventSync>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${LOCAL_DOCKER_IP}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH}
  echo "Replaced eventSync/hostName with ${LOCAL_DOCKER_IP}"

  # replace management/hostName
  sed -i "/<management>/,/<\/management>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${LOCAL_DOCKER_IP}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH}
  echo "Replaced management/hostName with ${LOCAL_DOCKER_IP}"

  # replace presentation/hostName
  sed -i "/<presentation>/,/<\/presentation>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${LOCAL_DOCKER_IP}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH}
  echo "Replaced presentation/hostName with ${LOCAL_DOCKER_IP}"
fi
