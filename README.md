# WSO2 Dockerfiles
WSO2 Dockerfiles define the resources and instructions to build the Docker images with the WSO2 products and runtime configurations.

## Try it out

The cloned local copy of WSO2 Dockerfiles will be referred as DOCKERFILES_HOME.

* Add product packs and dependencies
    - Download and copy JDK 1.7 ([jdk-7u80-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)) pack to `<DOCKERFILES_HOME>/common/scripts/provision/default/files` directory.
    - Download the necessary product packs and copy them to `<DOCKERFILES_HOME>/common/scripts/provision/default/files` directory. For example, for WSO2 API Manager 1.9.1 download the [product pack](http://wso2.com/products/api-manager/) and copy the zip file to `<DOCKERFILES_HOME>/common/scripts/provision/default/files`.

* Build docker image
    - Navigate to the module folder of the WSO2 product. For example, for WSO2 API Manager (eg: `<REPOSITORY_HOME>/wso2am`).
    - Execute `build.sh` script and provide the product version.
        + `./build.sh -v 1.9.1`

* Docker run
    - Navigate to the module folder of the WSO2 product. For example, for WSO2 API Manager (eg: `<REPOSITORY_HOME>/wso2am`).
    - Execute `run.sh` script and provide the product version.
        + `./run.sh -v 1.9.1`

* Access management console
    -  To access the management console, use the docker host ip and port 9443.
        + `https://<DOCKER_HOST_IP>:9443/carbon`

## Detailed description

* [Introduction] (https://docs.wso2.com/display/DF100/Introduction+to+Docker+Images)

* [Build docker images] (https://docs.wso2.com/display/DF100/Building+Product+Docker+Images)

* [Run docker images] (https://docs.wso2.com/display/DF100/Running+and+Migrating+Images)
