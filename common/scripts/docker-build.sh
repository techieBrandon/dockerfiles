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
    echoError "Insufficient or invalid options provided!"
    echo
    echoBold "Usage: ./build.sh -v [product-version] -i [docker-image-version] [OPTIONS]"
    echo

    op_versions=$(listFiles "${PUPPET_HOME}/hieradata/dev/wso2/wso2${product_name}/")
    op_versions_str=$(echo $op_versions | tr ' ' ',')
    op_versions_str="${op_versions_str//,/, }"

    op_profiles=$(listFiles "${PUPPET_HOME}/hieradata/dev/wso2/wso2${product_name}/$(echo $op_versions | head -n1 | awk '{print $1}')/")
    op_profiles_str=$(echo $op_profiles | tr ' ' ',')
    op_profiles_str="${op_profiles_str//.yaml/}"
    op_profiles_str="${op_profiles_str//,/, }"
    echo "Available product versions: ${op_versions_str}"
    echo "Available product profiles: ${op_profiles_str}"
    echo

    echoBold "Build Docker images for WSO2$(echo $product_name | awk '{print toupper($0)}')"
    echo
    echo -en "  -v\t"
    echo "[REQUIRED] Product version of WSO2$(echo $product_name | awk '{print toupper($0)}')"
    echo -en "  -i\t"
    echo "[REQUIRED] Docker image version"
    echo -en "  -l\t"
    echo "[OPTIONAL] '|' separated WSO2$(echo $product_name | awk '{print toupper($0)}') profiles to build. 'default' is selected if no value is specified."
    echo -en "  -e\t"
    echo "[OPTIONAL] Environment. 'dev' is selected if no value is specified."
    echo -en "  -q\t"
    echo "[OPTIONAL] Quiet flag. If used, the docker build run output will be suppressed"
    echo

    ex_version=$(echo ${op_versions_str} | head -n1 | awk '{print $1}')
    ex_profile=$(echo ${op_profiles_str} | head -n1 | awk '{print $1}')
    echoBold "Ex: ./build.sh -v ${ex_version//,/} -i 1.0.0 -l '${ex_profile//,/}'"
    echo
    exit 1
}

function cleanup() {
    echoBold "Cleaning..."
    rm -rf "$dockerfile_path/scripts"
    rm -rf "$dockerfile_path/puppet"
}

# $1 product name = esb
# $2 product version = 4.9.0
function validateProductVersion() {
    ver_dir="${PUPPET_HOME}/hieradata/dev/wso2/wso2${1}/${2}"
    if [ ! -d "$ver_dir" ]; then
        echoError "Provided product version wso2${1}:${2} doesn't exist in PUPPET_HOME: ${PUPPET_HOME}. Available versions are,"
        listFiles "${PUPPET_HOME}/hieradata/dev/wso2/wso2${1}/"
        echo
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
        echo
        showUsageAndExit
    fi
}

function validateDockerVersion(){
    IFS='.' read -r -a version_1 <<< "$1"
    IFS='.' read -r -a version_2 <<< "$2"
    for ((i=0; i<${#version_1[@]}; i++))
    do
        if (( "${version_1[i]}" < "${version_2[i]}" ))
            then
            echoError "Docker version should be equal to or greater than ${min_required_docker_version} to build WSO2 Docker images. Found ${docker_version}"
            exit 1
        fi
    done
}

verbose=true

while getopts :n:v:i:e:l:d:q FLAG; do
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
        l)
            product_profiles=$OPTARG
            ;;
        e)
            product_env=$OPTARG
            ;;
        d)
            dockerfile_path=$OPTARG
            ;;
        q)
            verbose=false
            ;;
        \?)
            showUsageAndExit
            ;;
    esac
done

prgdir2=$(dirname "$0")
self_path=$(cd "$prgdir2"; pwd)

# Check if a Puppet folder is set
if [ -z "$PUPPET_HOME" ]; then
    echoError "Puppet home folder could not be found! Set PUPPET_HOME environment variable pointing to local puppet folder."
    exit 1
fi

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

# check if provided product version exists in PUPPET_HOME
validateProductVersion "${product_name}" "${product_version}"

# check if provided profile exists in PUPPET_HOME
validateProfile "${product_name}" "${product_version}" "${product_profiles}"

# validate docker version against minimum required docker version
docker_version=$(docker version --format '{{.Server.Version}}')
min_required_docker_version=1.9.0
validateDockerVersion "${docker_version}" "${min_required_docker_version}"

# Copy common files to Dockerfile context
echoBold "Creating Dockerfile context..."
mkdir -p "${dockerfile_path}/scripts"
mkdir -p "${dockerfile_path}/puppet/modules"
cp "${self_path}/entrypoint.sh" "${dockerfile_path}/scripts/init.sh"

echoBold "Copying Puppet modules to Dockerfile context..."
cp -r "${PUPPET_HOME}/modules/wso2base" "${dockerfile_path}/puppet/modules/"
cp -r "${PUPPET_HOME}/modules/wso2${product_name}" "${dockerfile_path}/puppet/modules/"
cp -r "${PUPPET_HOME}/hiera.yaml" "${dockerfile_path}/puppet/"
cp -r "${PUPPET_HOME}/hieradata" "${dockerfile_path}/puppet/"
cp -r "${PUPPET_HOME}/manifests" "${dockerfile_path}/puppet/"

# Build image for each profile provided
IFS='|' read -r -a profiles_array <<< "${product_profiles}"
for profile in "${profiles_array[@]}"
do
    # set image name according to the profile list
    if [[ "${profile}" = "default" ]]; then
        image_id="wso2/${product_name}-${product_version}:${image_version}"
    else
        image_id="wso2/${product_name}-${profile}-${product_version}:${image_version}"
    fi

    image_exists=$(docker images $image_id | wc -l)
    if [ ${image_exists} == "2" ]; then
        askBold "Docker image \"${image_id}\" already exists? Overwrite? (y/n): "
        read -r overwrite_v
    fi

    if [ ${image_exists} == "1" ] || [ $overwrite_v == "y" ]; then

        # if there is a custom init.sh script supplied specific for the profile of this product, pack
        # it to ${dockerfile_path}/scripts/
        product_init_script_name="wso2${product_name}-${profile}-init.sh"
        if [[ -f "${dockerfile_path}/${product_init_script_name}" ]]; then
            pushd "${dockerfile_path}" > /dev/null
            cp "${product_init_script_name}" scripts/
            popd > /dev/null
        fi

        echoBold "Building docker image ${image_id}..."

        build_cmd="docker build --no-cache=true \
        --build-arg WSO2_SERVER=\"wso2${product_name}\" \
        --build-arg WSO2_SERVER_VERSION=\"${product_version}\" \
        --build-arg WSO2_SERVER_PROFILE=\"${profile}\" \
        --build-arg WSO2_ENVIRONMENT=\"${product_env}\" \
        -t \"${image_id}\" \"${dockerfile_path}\""

        {
            if [ $verbose == true ]; then
                ! eval $build_cmd | tee /dev/tty | grep -iq error && echo "Docker image ${image_id} created."
            else
                ! eval $build_cmd | grep -i error && echo "Docker image ${image_id} created."
            fi

        } || {
            echo
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
