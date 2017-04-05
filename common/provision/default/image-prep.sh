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

provision_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${provision_path}/../../scripts/base.sh"

jdk_archive=jdk-8u121-linux-x64.tar.gz

# Validate if files exist in the files folder
if [ ! -e "${provision_path}/files/${jdk_archive}" ]; then
    echoError "A valid JDK distribution was not found at ${provision_path}/files folder. Expected: ${jdk_archive}"
    exit 1
fi

if [ ! -e "${provision_path}/files/${product_name}-${product_version}.zip" ]; then
    echoError "$(echo $product_name | awk '{print toupper($0)}') ${product_version} pack was not found at ${provision_path}/files folder. Expected: ${product_name}-${product_version}.zip"
    exit 1
fi

export file_location=$provision_path/files
