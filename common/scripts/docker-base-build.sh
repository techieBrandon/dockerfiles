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
source "${DIR}/default-values.sh"

function showUsageAndExit() {
    echoError "Insufficient or invalid options provided!"
    echo
    echoBold "Usage: ./build.sh -v [product-version] "
    echo

    echoBold "Build Docker images for WSO2$(echo $product_name | awk '{print toupper($0)}')"
    echo
    echo -en "  -l\t"
    echo "[REQUIRED] Product version"
    echo

    exit 1
}

prgdir=$(dirname "$0")
self_path=$(cd "$prgdir"; pwd)

function cleanup {
    if [ ! -z $httpserver_pid ]; then
        echo "stopping local HTTP Server"
        kill -9 $httpserver_pid > /dev/null 2>&1
    fi
    echo "removing ${product_base_common_path}"
    rm -rf ${product_base_common_path}
}


while getopts :n:v:e:l:d:o:q FLAG; do
    case $FLAG in
        n)
            product_name='wso2'$OPTARG
            ;;
        v)
            product_version=$OPTARG
            ;;
        d)
            dockerfile_path=$OPTARG
            ;;
        \?)
            showUsageAndExit
            ;;
    esac
done

product_path="${dockerfile_path}/../"
product_base_path="${product_path}/base"
product_base_common_path="${product_base_path}/common"

mkdir -p "${product_base_common_path}"
mkdir -p "${product_base_common_path}/scripts"
cp "${self_path}/entrypoint.sh" "${product_base_common_path}/scripts/init.sh"
mkdir -p "${product_base_common_path}/jdk"
cp "${self_path}"/../../common/jdk/*  "${product_base_common_path}/jdk"
mkdir -p "${product_base_common_path}/pack"
cp ${product_path}/pack/"${product_name}-${product_version}".zip "${product_base_common_path}/pack"

function findHostIP() {
    local _ip _line
    while IFS=$': \t' read -a _line ;do
        [ -z "${_line%inet}" ] &&
           _ip=${_line[${#_line[1]}>4?1:2]} &&
           [ "${_ip#127.0.0.1}" ] && echo $_ip && return 0
    done< <(LANG=C /sbin/ifconfig)
}

# check if port 8000 is already in use
port_uses=$(lsof -i:8000 | wc -l)
if [ $port_uses -gt 1 ]; then
   echoError "Port 8000 seems to be already in use. Exiting..."
   cleanup
   exit 1
fi

# start the server in background
echo "starting a local HTTP server at ${product_base_common_path}"
pushd ${product_base_common_path} > /dev/null 2>&1
python -m SimpleHTTPServer 8000 & > /dev/null 2>&1
httpserver_pid=$!
sleep 5
popd > /dev/null 2>&1

# get host machine ip
host_ip=$(findHostIP)
if [ -z "$host_ip" ]; then
    echoError "Could not find host ip address. Exiting..."
    cleanup
    exit 1
fi

httpserver_address="http://${host_ip}:8000"
echoBold "HTTP server started at ${httpserver_address}"

echoBold "Building docker image ${image_id}..."

image_id=wso2/"${product_name}-${product_version}"

build_cmd="docker build --no-cache=true \
--build-arg WSO2_SERVER=${product_name} \
--build-arg WSO2_SERVER_VERSION=${product_version} \
--build-arg JDK_ARCHIVE=${jdk_archive} \
--build-arg JAVA_INSTALL_PATH=${java_install_path} \
--build-arg HTTP_PACK_SERVER=${httpserver_address} \
-t ${image_id} ${dockerfile_path}"

{
  #! eval $build_cmd | tee /dev/tty | grep -iq error && echo "Docker image ${image_id} created."
  $build_cmd && echo "Docker image ${image_id} created."

} || {
    echo
    echoError "ERROR: Docker image ${image_id} creation failed"
    cleanup
    exit 1
}

cleanup


