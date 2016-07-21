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

product_name=wso2/svn

self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${self_path}/../common/scripts/base.sh"

function showUsageAndExit() {
  echo
  echoBold "Usage: ./run.sh -v [product-version]"
  echo

  echoBold "Options:"
  echo
  echo -en "  -v\t"
  echo "[REQUIRED] Image version of $(echo $product_name | awk '{print toupper($0)}')"
  echo -en "  -u\t"
  echo "[OPTIONAL] Username for SVN Server. If not provided, default \"admin\" is used."
  echo -en "  -p\t"
  echo "[OPTIONAL] Password for SVN Server. If not provided, default \"admin\" is used."
  echo -en "  -l\t"
  echo "[OPTIONAL] Repository list for SVN. Based on the list repos will be created. If not provided, repository will be created with name repo."
  echo -en "  -h\t"
  echo "[OPTIONAL] Show help text."

  echoBold "Ex: ./run.sh -v 1.0.0 -u username -p password -l esb,das"
  echo
  exit 1
}

while getopts :v:u:p:l:h FLAG; do
    case $FLAG in
        v)
            product_version=$OPTARG
            ;;
        u)
            username=$OPTARG
            env_values="-e USERNAME=${username}"
            ;;
        p)
            password=$OPTARG
            env_values="${env_values} -e PASSWORD=${password}"
            ;;
        l)
            repo_list=$OPTARG
            env_values="${env_values} -e REPO_LIST=${repo_list}"
            ;;
        h)
            showUsageAndExit
            ;;
        \?)
            showUsageAndExit
            ;;
    esac
done

if [[ -z ${product_version} ]]; then
  showUsageAndExit
fi

echoBold "Running SVN docker container..."

container_id=$(docker run ${env_values} -d -p 8080:80 ${product_name}:${product_version})

member_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${container_id}")
if [ -z "${member_ip}" ]; then
    echoError "Couldn't start container ${container_id} with name ${product_name}"
    exit 1
fi

product_name_in_uppercase=`echo ${product_name} | tr '[:lower:]' '[:upper:]'`
echoSuccess "${product_name_in_uppercase} container started: [name] ${product_name} [ip] ${member_ip} [container-id] ${container_id}"
sleep 1

echo
askBold "Connect to the spawned container? (y/n): "
read -r exec_v
if [[ "$exec_v" == "y" || "$exec_v" == "Y" ]]; then
    docker exec -it "${container_id}" /bin/bash
else
    askBold "Tail container logs? (y/n): "
    read -r exec_v
    if [[ "$exec_v" == "y" || "$exec_v" == "Y" ]]; then
      docker logs -f "${container_id}"
    fi
fi


