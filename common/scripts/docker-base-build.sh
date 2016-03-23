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

product_name=$1
product_version=$2

if [[ -z ${product_name} ]];
then
    echo "product name required. ex.: ./docker-base-build.sh wso2am 1.9.1"
    exit 1
fi
if [[ -z ${product_version} ]];
then
    echo "product version required. ex.: ./docker-base-build.sh wso2am 1.9.1"
    exit 1
fi

prgdir=$(dirname "$0")
self_path=$(cd "$prgdir"; pwd)
# copy common stuff (entrypoint.sh and jdk)

function cleanup {
    rm -rf ${product_base_common_path}
}

product_base_path="${self_path}/../../${product_name}/base"
product_base_common_path="${product_base_path}/common"
mkdir -p "${product_base_common_path}"
mkdir -p "${product_base_common_path}/scripts"
cp "${self_path}/entrypoint.sh" "${product_base_common_path}/scripts/init.sh"
mkdir -p "${product_base_common_path}/jdk"
cp "${self_path}"/../../common/jdk/*  "${product_base_common_path}/jdk"

echoBold "Building docker image ${image_id}..."

image_id=wso2/"${product_name}-${product_version}"
dockerfile_path=${product_base_path}

build_cmd="docker build --no-cache=true \
--build-arg WSO2_SERVER=${product_name} \
--build-arg WSO2_SERVER_VERSION=${product_version} \
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


