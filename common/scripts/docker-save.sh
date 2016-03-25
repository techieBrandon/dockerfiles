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
    echoBold "Usage: ./save.sh -v [product-version]"
    echo

    op_pversions=$(docker images | grep wso2/$product_name | awk '{print $1,"\t- ", $2}')
    if [ -n "$op_pversions" ]; then
        echo "Available product images:"
        echo "$op_pversions"
        echo
    fi

    echoBold "Save WSO2$(echo $product_name | awk '{print toupper($0)}') Docker images to tarballs to ${HOME}/docker/images"
    echo
    echo -en "  -v\t"
    echo "[REQUIRED] Product version of WSO2$(echo $product_name | awk '{print toupper($0)}')"
    echo -en "  -i\t"
    echo "[OPTIONAL] Docker image version."
    echo -en "  -l\t"
    echo "[OPTIONAL] '|' separated WSO2$(echo $product_name | awk '{print toupper($0)}') profiles to save. 'default' is selected if no value is specified."
    echo -en "  -o\t"
    echo "[OPTIONAL] Organization name. 'wso2' is selected if no value is specified."
    echo

    echoBold "Ex: ./save.sh -v 1.9.1 -l 'manager'"
    echo
    exit 1
}

while getopts :n:v:i:o:l: FLAG; do
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
        o)
            organization_name=$OPTARG
            ;;
        l)
            product_profiles=$OPTARG
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

if [ -z "$product_profiles" ]
  then
    product_profiles='default'
fi

if [ -z "$organization_name" ]
  then
    organization_name='wso2'
fi


IFS='|' read -r -a array <<< "${product_profiles}"
for profile in "${array[@]}"
do
    image_id="${organization_name}/${product_name}-${profile}:${product_version}"
        tar_file="${product_name}-${profile}-${product_version}.tar"

    if [ -z "$image_version" ]; then
        image_id="${organization_name}/${product_name}-${profile}:${product_version}"
        tar_file="${product_name}-${profile}-${product_version}.tar"
    else
        image_id="${organization_name}/${product_name}-${profile}:${product_version}-${image_version}"
        tar_file="${product_name}-${profile}-${product_version}-${image_version}.tar"
    fi

    echo "Saving docker image ${image_id} to ${HOME}/docker/images/${tar_file}"
    mkdir -p "${HOME}/docker/images/"
    docker save "${image_id}" > "${HOME}/docker/images/${tar_file}"

    echoSuccess "Docker image ${image_id} saved to ${HOME}/docker/images/${tar_file}."
done
