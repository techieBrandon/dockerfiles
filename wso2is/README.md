# Dockerfile for WSO2 Identity Server #
The Dockerfile define the resources and instructions to build the Docker images with the WSO2 products and runtime configurations. This process uses Puppet and Hiera to configure the Docker images.

## Try it out
Quick steps to build the WSO2 Identity Server docker image and run in your local machine

* Get Puppet Modules
    - The Puppet modules for WSO2 products can be found in the [WSO2 Puppet Modules repository](https://github.com/wso2/puppet-modules). You can obtain the latest release from the [releases page](https://github.com/wso2/puppet-modules/releases).
    - After getting the `wso2-puppet-modules-<version>.zip` file, extract it and set `PUPPET_HOME` environment variable pointing to extracted folder.

* Add product packs and dependencies
    - Download and copy JDK 1.7 ([jdk-7u80-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)) pack to `<PUPPET_HOME>/modules/wso2base/files`
    - Download the necessary product packs and copy them to `<PUPPET_HOME>/modules/<MODULE>/files`. For example, for WSO2 Identity Server 5.1.0 download the [product pack](http://wso2.com/products/identity-server/) and copy the zip file to `<PUPPET_HOME>/modules/wso2is/files`.

* Build the docker image
    - First build the base image `wso2/base` by executing `build.sh` script inside `<REPOSITORY_HOME>/common/base-image`.
    - Navigate to `<REPOSITORY_HOME>/wso2is`.
    - Execute `build.sh` script and provide the product version, image version and the product profiles to be built.
        + `./build.sh -v 5.1.0 -i 1.0.0`

* Docker run
    - Execute `run.sh` script and provide the product version, image version and the product profiles to be run.
        + `./run.sh -v 5.1.0 -i 1.0.0`

* Access management console
    - Add an `/etc/hosts` entry in your local machine for `<docker_host_ip> is.wso2.com`. For example:
        + `127.0.0.1       is.wso2.com`
    -  To access the management console.
        + `https://is.wso2.com:32002/carbon`

## Detailed Configurations

* [Introduction] (https://docs.wso2.com/display/DF100/Introduction+to+Docker+Images)

* [Building docker images] (https://docs.wso2.com/display/DF100/Building+Product+Docker+Images)

* [Running docker images] (https://docs.wso2.com/display/DF100/Running+and+Migrating+Images)
