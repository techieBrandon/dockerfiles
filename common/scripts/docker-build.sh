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
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/base.sh"

# Show usage and exit
function showUsageAndExit() {
    echoBold "Usage: ./build.sh [product-version] [docker-image-version] [product_profile_list]"
    echo "Ex: ./build.sh 1.9.1 1.0.0 'default|worker|manager'"
    exit 1
}

function cleanup() {
    echoBold "Cleaning..."
    rm -rf "$dockerfile_path/scripts"
    rm -rf "$dockerfile_path/puppet"
}

function listFiles () {
    find "${1}" -maxdepth 1 -mindepth 1 -printf "%f\n"
    echo
    # for n in "${1}"; do echo "${n%%.*}"; done
    # for n in "${1}"; do echo "${n}"; done
}

# $1 product name = esb
# $2 product version = 4.9.0
function validateProductVersion() {
    ver_dir="${PUPPET_HOME}/hieradata/dev/wso2/wso2${1}/${2}"
    if [ ! -d "$ver_dir" ]; then
        echoError "Provided product version wso2${1}:${2} doesn't exist in PUPPET_HOME: ${PUPPET_HOME}. Available versions are,"
        listFiles "${PUPPET_HOME}/hieradata/dev/wso2/wso2${1}/"
        showUsageAndExit
    fi
}

# $1 product name = esb
# $2 product version = 4.9.0
# $3 product profile list = 'default|worker|manager'
function validateProfile() {
    invalidFound=false
    IFS='|' read -r -a array <<< "${3}"
    for profile in "${array[@]}"
    do
        profile_yaml="${PUPPET_HOME}/hieradata/dev/wso2/wso2${1}/${2}/${profile}.yaml"
        if [ ! -e "${profile_yaml}" ] || [ ! -s "${profile_yaml}" ]
        then
            invalidFound=true
        fi
    done

    if [ "${invalidFound}" == true ]
    then
        echoError "One or more provided product profiles wso2${1}:${2}-[${3}] do not exist in PUPPET_HOME: ${PUPPET_HOME}. Available profiles are,"
        listFiles "${PUPPET_HOME}/hieradata/dev/wso2/wso2${1}/${2}/"
        showUsageAndExit
    fi
}

dockerfile_path=$1
image_version=$2
product_name=$3
product_version=$4
product_profiles=$5
product_env=$6

prgdir2=$(dirname "$0")
self_path=$(cd "$prgdir2"; pwd)

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
    product_profiles="default"
fi

if [ -z "$product_env" ]; then
    product_env="dev"
fi

# Check if a Puppet folder is set
if [ -z "$PUPPET_HOME" ]; then
   echoError "Puppet home folder could not be found! Set PUPPET_HOME environment variable pointing to local puppet folder."
   exit 1
else
   puppet_path=$PUPPET_HOME
   echoBold "PUPPET_HOME is set to ${puppet_path}."
fi

# check if provided product version exists in PUPPET_HOME
validateProductVersion "${product_name}" "${product_version}"

# check if provided profile exists in PUPPET_HOME
validateProfile "${product_name}" "${product_version}" "${product_profiles}"

docker_version=$(docker version --format '{{.Server.Version}}')
echoBold "Docker version should be equal to or later than 1.9.0 to build WSO2 Docker images. Found ${docker_version}"
echo

# Copy common files to Dockerfile context
echoBold "Creating Dockerfile context..."
mkdir -p "${dockerfile_path}/scripts"
mkdir -p "${dockerfile_path}/puppet/modules"
cp "${self_path}/entrypoint.sh" "${dockerfile_path}/scripts/init.sh"

echoBold "Copying Puppet modules to Dockerfile context..."
cp -r "${puppet_path}/modules/wso2base" "${dockerfile_path}/puppet/modules/"
cp -r "${puppet_path}/modules/wso2${product_name}" "${dockerfile_path}/puppet/modules/"
cp -r "${puppet_path}/hiera.yaml" "${dockerfile_path}/puppet/"
cp -r "${puppet_path}/hieradata" "${dockerfile_path}/puppet/"
cp -r "${puppet_path}/manifests" "${dockerfile_path}/puppet/"

# Build image for each profile provided
IFS='|' read -r -a array <<< "${product_profiles}"
for profile in "${array[@]}"
do
    # set image name according to the profile list
    if [[ "${profile}" = "default" ]]; then
        image_id="wso2/${product_name}-${product_version}:${image_version}"
        docker images | grep -F "wso2/${product_name}-${product_version}" | awk '{print $2}' | grep -Fx "${image_version}" > /dev/null 2>&1
        image_exists=$?
    else
        image_id="wso2/${product_name}-${profile}-${product_version}:${image_version}"
        docker images | grep -F "wso2/${product_name}-${profile}-${product_version}" | awk '{print $2}' | grep -Fx "${image_version}" > /dev/null 2>&1
        image_exists=$?
    fi

    if [ "$image_exists" -eq 0 ]; then
        askBold "Docker image \"${image_id}\" already exists? Overwrite? (y/n): "
        read -r overwrite_v
    fi

    if [ "$image_exists" -eq 1 ] || [ "$overwrite_v" == "y" ]; then

        # if there is a custom init.sh script supplied specific for the profile of this product, pack
        # it to ${dockerfile_path}/scripts/
        product_init_script_name="wso2${product_name}-${profile}-init.sh"
        if [[ -f "${dockerfile_path}/${product_init_script_name}" ]]; then
            pushd "${dockerfile_path}" > /dev/null
            cp "${product_init_script_name}" scripts/
            popd > /dev/null
        fi

        echoBold "Building docker image ${image_id}..."

        {
            # show only errors from the docker build output
            ! docker build --no-cache=true \
            --build-arg WSO2_SERVER="wso2${product_name}" \
            --build-arg WSO2_SERVER_VERSION="${product_version}" \
            --build-arg WSO2_SERVER_PROFILE="${profile}" \
            --build-arg WSO2_ENVIRONMENT="${product_env}" \
            -t "${image_id}" "${dockerfile_path}" | grep -i error && echo "Docker image ${image_id} created."
        } || {
            echoError "ERROR: Docker image ${image_id} creation failed"
            cleanup
            exit 1
        }
    else
        echoBold "Not overwriting \"${image_id}\"..."
    fi
done

cleanup
echoSuccess "Build process completed"
