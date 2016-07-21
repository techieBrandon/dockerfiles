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
  echoBold "Usage: ./build.sh -v [product-version]"
  echo

  echoBold "Options:"
  echo
  echo -en "  -v\t"
  echo "[REQUIRED] Image version of $(echo $product_name | awk '{print toupper($0)}')"
  echo -en "  -h\t"
  echo "[OPTIONAL] Show help text."

  echoBold "Ex: ./build.sh -v 1.0.0 "
  echo
  exit 1
}

while getopts :v:h FLAG; do
    case $FLAG in
        v)
            product_version=$OPTARG
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

echoBold "Building SVN docker image..."
docker build -t ${product_name}:${product_version} ${self_path}