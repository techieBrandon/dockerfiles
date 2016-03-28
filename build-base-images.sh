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
source common/scripts/base.sh

function build() {
  product_name=$1
  product_version=$2
  image_tag=wso2/${product_name}:${product_version}
  image_exists=$(docker images $image_tag | wc -l)
  if [ ${image_exists} == "2" ]; then
    # docker image already built
    echoBold "Docker image ${image_tag} already exist, skipping..."
  else
    # docker image not found
    echoBold "==> Building ${image_tag}"
    pushd ${product_name}/base
    ./build.sh -v ${product_version}
    popd
    echoSuccess "==> ${product_name} ${product_version} build completed!"
  fi
}

# Update the below product list and versions as required
echoBold "Building base docker images..."
build wso2am 1.9.1
build wso2as 5.3.0
build wso2bps 3.5.0
build wso2brs 2.2.0
build wso2cep 4.1.0
build wso2das 3.0.1
build wso2dss 3.5.0
build wso2es 2.0.0
build wso2esb 4.9.0
build wso2greg 5.1.0
build wso2is 5.1.0
build wso2mb 3.1.0
echoSuccess "Base docker images build successfully!"
