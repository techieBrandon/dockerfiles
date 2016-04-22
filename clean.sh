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

function remove() {
  product_name=$1
  product_version=$2
  image_tag=${product_name}:${product_version}
  image_exists=$(docker images $image_tag | wc -l)
  if [ ${image_exists} == "2" ]; then
    echoBold "Removing docker image ${image_tag}..."
    docker rmi -f ${image_tag}
    echoSuccess "==> ${product_name} ${product_version} removed"
  fi
}

# Update the below product list and versions as required
echoBold "Removing WSO2 docker images..."
remove wso2am 1.10.0
remove wso2as 5.3.0
remove wso2bps 3.5.0
remove wso2brs 2.2.0
remove wso2cep 4.1.0
remove wso2das 3.0.1
remove wso2dss 3.5.0
remove wso2es 2.0.0
remove wso2esb 4.9.0
remove wso2greg 5.1.0
remove wso2is 5.1.0
remove wso2mb 3.1.0
echoSuccess "WSO2 docker images removed successfully!"
