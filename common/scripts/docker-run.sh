#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2005-2015 WSO2, Inc. (http://wso2.com)
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
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/base.sh"

function showUsageAndExit () {
    echoError "Insufficient or invalid options provided!"
    echoBold "Usage: ./run.sh -v [product-version] -i [docker-image-version] [OPTIONAL] -l [product-profile-list] [OPTIONAL] -p [port-mappings] [OPTIONAL] -k [key-store-password]"
    echo "eg: ./run.sh -v 1.9.1 -i 1.0.0 -l 'default|worker|manager' -k 'wso2carbon'"
    exit 1
}

while getopts :n:v:i:p:l:k: FLAG; do
    case $FLAG in
        n)
            product_name=$OPTARG
            ;;
        v)
            product_version=$OPTARG
            ;;
        i)
            image_version=$OPTARG
            ;;
        l)
            product_profiles=$OPTARG
            ;;
        p)
            port_mappings="${port_mappings} -p $OPTARG"
            ;;
        k)
            key_store_password=$OPTARG
            ;;
        \?)
            showUsageAndExit
            ;;
    esac
done

# Validate mandatory args
if [ -z "$product_version" ]
  then
    showUsageAndExit
fi

if [ -z "$image_version" ]
  then
    showUsageAndExit
fi

if [ -z "$product_profiles" ]
  then
    product_profiles='default'
fi

if [ -z "$port_mappings" ]
  then
    port_mappings='-P'
fi

if [ -z "$key_store_password" ]; then
    env_key_store_password=
else
    env_key_store_password="-e KEY_STORE_PASSWORD=${key_store_password}"
fi

IFS='|' read -r -a profiles_array <<< "${product_profiles}"
for profile in "${profiles_array[@]}"
do
    name="wso2${product_name}-${profile}"

    existing_container=$(docker ps -a | awk '{print $NF}' | grep "${name}")
    if [[ $existing_container = "$name" ]]; then
        echoError "A Docker container with the name ${name} already exists."
        askBold "Terminate existing ${name} container (y/n): "
        read -r terminate
        if [[ $terminate = "y" ]]; then
            docker rm -f "${name}" > /dev/null 2>&1 || { echoError "Couldn't terminate container ${name}."; exit 1; }
        else
            exit 1
        fi
    fi

    if [[ $profile = "default" ]]; then
        container_id=$(docker run -d ${port_mappings} ${env_key_store_password} --name "${name}" "wso2/${product_name}-${product_version}:${image_version}")
    else
        container_id=$(docker run -d ${port_mappings} ${env_key_store_password} --name "${name}" "wso2/${product_name}-${profile}-${product_version}:${image_version}")
    fi

    member_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${container_id}")
    if [ -z "${member_ip}" ]; then
        echoError "Couldn't start container ${container-id} with name ${name}"
        exit 1
    fi

    echoSuccess "WSO2 ${product_name^^} ${profile} member started: [name] ${name} [ip] ${member_ip} [container-id] ${container_id}"
    sleep 1

done

if [ "${#profiles_array[@]}" -eq 1 ]; then
    echo
    askBold "Open a Bash terminal on the spawned container? (y/n): "
    read -r exec_v
    if [ "$exec_v" == "y" ]; then
        docker exec -it "${container_id}" /bin/bash
    fi
else
    echo "To get bash into a running container use following command..."
    echo "docker exec -it <containerId or name> bash"
fi
