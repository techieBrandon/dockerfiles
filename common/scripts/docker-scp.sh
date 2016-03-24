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

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/base.sh"

function showUsageAndExit () {
    echoError "Insufficient or invalid options provided!"
    echo
    echoBold "Usage: ./scp.sh -h [host-list] -v [product-version]"
    echo

    op_images=$(listFiles "${HOME}/docker/images" | grep $product_name)
    if [ -n "$op_images" ]; then
        echo "Available tarballs:"
        echo "$op_images"
        echo
    fi

    echoBold "SCP saved Docker images for $(echo $product_name | awk '{print toupper($0)}') to specified hosts"
    echo
    echo -en "  -h\t"
    echo "[REQUIRED] The '|' separated list of hosts to transfer the Docker images. This should be of format 'user@ip1|user@ip2|user@ip3'"
    echo -en "  -v\t"
    echo "[REQUIRED] Product version of $(echo $product_name | awk '{print toupper($0)}')"
    echo -en "  -l\t"
    echo "[OPTIONAL] '|' separated $(echo $product_name | awk '{print toupper($0)}') profiles to SCP. 'default' is selected if no value is specified."
    echo

    echoBold "Ex: ./scp.sh -h 'core@172.17.8.102|core@172.17.8.103' -v 1.9.1 -l 'manager'"
    echo
    exit 1
}

while getopts :n:v:l:h: FLAG; do
    case $FLAG in
        n)
            product_name=$OPTARG
            ;;
        v)
            product_version=$OPTARG
            ;;
        l)
            product_profiles=$OPTARG
            ;;
        h)
            nodes=$OPTARG
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

if [ -z "$nodes" ]
  then
    showUsageAndExit
fi

if [ -z "$product_profiles" ]
  then
    product_profiles='default'
fi

IFS='|' read -r -a array <<< "${product_profiles}"
for profile in "${array[@]}"
do
    if [[ $profile = "default" ]]; then
        tar_file="${product_name}-${product_version}.tar"
    else
        tar_file="${product_name}-${profile}-${product_version}.tar"
    fi

    IFS='|' read -r -a array2 <<< "${nodes}"
    for node in "${array2[@]}"
    do
        if [ -e ~/.ssh/known_hosts ]; then
            ssh "${node}" 'pwd' > /dev/null 2>&1 || {
                exit_code=$? # exit code of the last command
                if [ "$exit_code" == "255" ]; then
                    echoError "Specified node's host identification fails: ${node}"
                    askBold "Clear ~/.ssh/known_hosts ? (y/n): "
                    read -r remove_knownhosts

                    if [ "$remove_knownhosts" = "y" ]; then
                        mv ~/.ssh/known_hosts ~/.ssh/hostfile.bck
                        echoDim "Renamed ~/.ssh/known_hosts to ~/.ssh/hostfile.bck"
                    fi
                else
                    echoError "Connection to specified node failed: ${node}. SCP commands may fail."
                fi
            }
        fi

        echo "Copying ${HOME}/docker/images/${tar_file} to ${node}..."
        scp "${HOME}/docker/images/${tar_file}" "${node}:"
        echo "Loading ${tar_file} to Docker in ${node}..."
        ssh "${node}" "docker load < ${tar_file}"
        echo "Deleting ${tar_file} in ${node}..."
        ssh "${node}" "rm ${tar_file}"
    done
done
