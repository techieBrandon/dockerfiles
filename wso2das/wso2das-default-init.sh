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
set -e
EVENT_PROCESSOR_XML_FILE_PATH=${CARBON_HOME}/repository/conf/event-processor.xml
SPARK_DEFAULTS_CONF_FILE_PATH=${CARBON_HOME}/repository/conf/analytics/spark/spark-defaults.conf
SPARK_ENV_SCRIPT_FILE_PATH=${CARBON_HOME}/bin/load-spark-env-vars.sh
PORTAL_DESIGNER_FILE_PATH=${CARBON_HOME}/repository/deployment/server/jaggeryapps/portal/configs/designer.json

# Update Spark driver bind address to Docker runtime IP address
#sed -i "s/spark\.driver\.host.*/spark.driver.host ${LOCAL_DOCKER_IP}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
#&& echo "Replaced spark.driver.host with ${LOCAL_DOCKER_IP}"

# Due to lack of built-in overlay network in Mesos, we need to bind to host IP and dynamic proxy ports
# This is only useful in standalone mode. Use DCOS Spark framework to deploy a Spark cluster in Mesos with wso2das running in Spark client mode
if [[ $PLATFORM == "mesos" ]]; then

  # Update Spark ports with dynamically generated Mesos port mappings
  sed -i "s/spark\.ui\.port.*/spark.ui.port ${PORT5}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
  && echo "Replaced spark.ui.port with ${PORT5}"

  # replace eventSync/hostName
  sed -i "/<eventSync>/,/<\/eventSync>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${HOST}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced eventSync/hostName with ${HOST}"

  # replace eventSync/port
  sed -i "/<eventSync>/,/<\/eventSync>/ s|<port>[0-9a-z.]\{1,\}</port>|<port>${PORT6}</port>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced eventSync/port with ${PORT6}"

  # replace management/hostName
  sed -i "/<management>/,/<\/management>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${HOST}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced management/hostName with ${HOST}"

  # replace management/port
  sed -i "/<management>/,/<\/management>/ s|<port>[0-9a-z.]\{1,\}</port>|<port>${PORT7}</port>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced management/port with ${PORT7}"

  # replace presentation/hostName
  sed -i "/<presentation>/,/<\/presentation>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${HOST}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced presentation/hostName with ${HOST}"

  # replace presentation/port
  sed -i "/<presentation>/,/<\/presentation>/ s|<port>[0-9a-z.]\{1,\}</port>|<port>${PORT8}</port>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced presentation/port with ${PORT8}"

  # replace spark specific ports
  sed -i "s/spark\.master\.webui\.port.*/spark.master.webui.port ${PORT9}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
  && echo "Replaced spark.master.webui.port with ${PORT9}"

  sed -i "s/spark\.worker\.webui\.port.*/spark.worker.webui.port ${PORT10}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
  && echo "Replaced spark.worker.webui.port with ${PORT10}"

  sed -i "s/spark\.master\.port.*/spark.master.port ${PORT11}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
  && echo "Replaced spark.master.port with ${PORT11}"

  sed -i "s/spark\.driver\.port.*/spark.driver.port ${PORT12}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
  && echo "Replaced spark.driver.port with ${PORT12}"

  sed -i "s/spark\.worker\.port.*/spark.worker.port ${PORT13}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
  && echo "Replaced spark.worker.port with ${PORT13}"

  sed -i "s/spark\.executor\.port.*/spark.executor.port ${PORT14}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
  && echo "Replaced spark.executor.port with ${PORT14}"

  # replace hostname in designer.json (https://wso2.org/jira/browse/UES-689)
#  sed -i "s#\"hostname\"[^,]*,#\"hostname\": ${HOST},#" ${PORTAL_DESIGNER_FILE_PATH} \
#  && echo "Replaced hostname in designer.json with ${HOST}"
#
#  sed -i "s/spark\.history\.ui\.port.*/spark.history.ui.port ${PORT6}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
#  && echo "Replaced spark.history.ui.port with ${PORT6}"
#
#  sed -i "s/spark\.blockManager\.port.*/spark.blockManager.port ${PORT7}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
#  && echo "Replaced spark.blockManager.port with ${PORT7}"
#
#  sed -i "s/spark\.broadcast\.port.*/spark.broadcast.port ${PORT8}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
#  && echo "Replaced spark.broadcast.port with ${PORT8}"
#
#  sed -i "s/spark\.fileserver\.port.*/spark.fileserver.port ${PORT11}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
#  && echo "Replaced spark.fileserver.port with ${PORT11}"
#
#  sed -i "s/spark\.replClassServer\.port.*/spark.replClassServer.port ${PORT12}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
#  && echo "Replaced spark.replClassServer.port with ${PORT12}"
#
#  sed -i "s/spark\.master\.rest\.port.*/spark.master.rest.port ${PORT14}/g" ${SPARK_DEFAULTS_CONF_FILE_PATH} \
#  && echo "Replaced spark.master.rest.port with ${PORT14}"

else
  # replace eventSync/hostName
  sed -i "/<eventSync>/,/<\/eventSync>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${LOCAL_DOCKER_IP}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced eventSync/hostName with ${LOCAL_DOCKER_IP}"

  # replace management/hostName
  sed -i "/<management>/,/<\/management>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${LOCAL_DOCKER_IP}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced management/hostName with ${LOCAL_DOCKER_IP}"

  # replace presentation/hostName
  sed -i "/<presentation>/,/<\/presentation>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${LOCAL_DOCKER_IP}</hostName>|g" ${EVENT_PROCESSOR_XML_FILE_PATH} \
  && echo "Replaced presentation/hostName with ${LOCAL_DOCKER_IP}"
fi
