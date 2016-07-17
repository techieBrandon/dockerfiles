#!/bin/bash

# ------------------------------------------------------------------------
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
self_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source ${self_path}/common/scripts/base.sh

# Build image for given product and version
# $1 - product name
# $2 - product version
# $3 - product profiles
function build_image() {
  product_name=$1
  product_version=$2
  product_profiles=$3
  echoBold "Building ${product_name}-${product_version}, profiles: ${product_profiles}"
  pushd ${self_path}/${product_name}/
  ./build.sh -v ${product_version} -l ${product_profiles}
  popd
  echoSuccess "${image_tag} build completed!"
}

while getopts :n:v:l: FLAG; do
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
  esac
done

if [[ -z $product_name ]] || [[ -z $product_version ]] || [[ -z $product_profiles ]]; then
  echo "Building all images..."
  build_image wso2am 1.10.0 "default|api-key-manager|api-publisher|api-store|gateway-manager|gateway-worker"
  build_image wso2as 5.3.0 "default|worker|manager"
  build_image wso2bps 3.5.1 "default|worker|manager"
  build_image wso2brs 2.2.0 "default|worker|manager"
  build_image wso2cep 4.0.0 default
  build_image wso2das 3.0.1 default
  build_image wso2dss 3.5.0 "default|worker|manager"
  build_image wso2es 2.0.0 "default|store|publisher"
  build_image wso2esb 4.9.0 "default|worker|manager"
  build_image wso2greg 5.1.0 default
  build_image wso2greg-pubstore 5.1.0 default
  build_image wso2is 5.1.0 default
  build_image wso2is-km 5.1.0 default
  build_image wso2mb 3.1.0 default
else
  echoBold "Building ${product_name}:${product_version}, profiles: ${product_profiles}"
  pushd ${self_path}/${product_name}/
  ./build.sh "$@"
  popd
  echoSuccess "${image_tag} build completed!"
fi

echoBold "Done"
