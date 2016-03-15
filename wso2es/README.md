# Dockerfile for WSO2 Enterprise Store #
The Dockerfile define the resources and instructions to build the Docker images with the WSO2 products and runtime configurations. This process uses Puppet and Hiera to update the configuration.

## Try it out
Quick steps to build the WSO2 Enterprise Store docker image and run in your local machine
  
* Get Puppet Modules
    - The Puppet modules for WSO2 products can be found in the [WSO2 Puppet Modules repository](https://github.com/wso2/puppet-modules). You can obtain the latest release from the [releases page](https://github.com/wso2/puppet-modules/releases). 
    - After getting the `wso2-puppet-modules-<version>.zip` file, extract it and set `PUPPET_HOME` environment variable pointing to extracted folder.

* Add product packs and dependencies
    - Download and copy JDK 1.7 ([jdk-7u80-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)) pack to `<PUPPET_HOME>/modules/wso2base/files`
    - Download the necessary product packs and copy them to `<PUPPET_HOME>/modules/<MODULE>/files`. For example, for WSO2 Enterprise Store 2.0.0 download the [product pack](http://wso2.com/products/enterprise-store/) and copy the zip file to `<PUPPET_HOME>/modules/wso2es/files`.

* Build the docker image
    - First build the base image by executing `build.sh` script. (eg: `<REPOSITORY_HOME>/common/docker/base-image`)
    - Navigate to the `docker` folder inside the module wso2es. (eg: `<REPOSITORY_HOME>/wso2es/docker`).
    - Execute `build.sh` script and provide the product version, image version and the product profiles to be built.
        + `./build.sh -v 2.0.0 -i 1.0.0`

* Docker run
    - Execute `run.sh` script and provide the product version, image version and the product profiles to be run.
        + `./run.sh -v 2.0.0 -i 1.0.0`

* Access management console
    - Add an etc/hosts entry in your local machine for `<docker_host_ip> es.wso2.com`. For example:
        + `127.0.0.1       es.wso2.com`
    -  To access the management console.
        + `https://es.wso2.com:32002/carbon`

## Building the Docker Images

* Get Puppet Modules
    - The Puppet modules for WSO2 products can be found in the [WSO2 Puppet Modules repository](https://github.com/wso2/puppet-modules). You can obtain the latest release from the [releases page](https://github.com/wso2/puppet-modules/releases). 
    - After getting the `wso2-puppet-modules-<version>.zip` file, extract it and set `PUPPET_HOME` environment variable pointing to extracted folder. 
    - Modify the Hiera files as needed. For example, for WSO2 Enterprise Store 2.0.0, edit the heira data from the profiles found at `wso2-puppet-modules-<version>/heiradata/dev/wso2/wso2es/2.0.0/` 

* Add product packs and dependencies
    - Download and copy JDK 1.7 ([jdk-7u80-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)) pack to `<PUPPET_HOME>/modules/wso2base/files`
    - Download the necessary product packs and copy them to `<PUPPET_HOME>/modules/<MODULE>/files`. For example, for WSO2 Enterprise Store 2.0.0 download the [product pack](http://wso2.com/products/enterprise-store/) and copy the zip file to `<PUPPET_HOME>/modules/wso2es/files`.

* Advanced configuration
    - Copy any deployable artifacts to the wso2es module's `files` folder. For example, for WSO2 Enterprise Store 2.0.0, copy any deployable applications to `<PUPPET_HOME>/modules/wso2es/files/configs/repository/deployment/server`.
    - Copy any patches to the wso2es module's `files` folder. For example, for WSO2 Enterprise Store 2.0.0, copy any patches to `<PUPPET_HOME>/modules/wso2es/files/patches/repository/components/patches`.
    - For clustering scenario in Kubernetes. Build the [Carbon Kubernetes Membership Scheme](https://github.com/wso2/kubernetes-artifacts/tree/master/common/kubernetes-membership-scheme) and copy the following jar to `<PUPPET_HOME>/modules/wso2es/files/configs/repository/components/lib` folder. Furthermore, copy the dependencies for the Carbon Kubernetes Membership Scheme to the same place.
        + jackson-annotations-2.5.4.jar
        + jackson-core-2.5.4.jar
        + jackson-databind-2.5.4.jar
        + kubernetes-membership-scheme-1.0.0.jar

* Build the docker images
    - First build the base image by executing `build.sh` script. (eg: `<REPOSITORY_HOME>/common/docker/base-image`)
    - Navigate to the `docker` folder inside the module wso2es. (eg: `<REPOSITORY_HOME>/wso2es/docker`).
    - Usage: `./build.sh -v [product-version] -i [docker-image-version] [OPTIONAL] -l [product-profile-list] [OPTIONAL] -e [product-env] [OPTIONAL] -q [quiet-mode]`
        + `-v [product-version]` to specify the product version
        + `-i [docker-image-version]` to specify the docker image version
        + `-l [product-profile-list]` it is optional, to specify the product profile list. If nothing is specified, it will build the default profile. 
        + `-e [product-env]` it is optional, to specify the product environment which could be found under heiradata in puppet modules. If nothing is specified, it will take 'dev' as the default value.
        + `-q [quiet-mode]` it is optional, to build the docker image in quiet mode, without docker build logs.
    - Execute `build.sh` script and provide the product version, image version and the product profiles to be built.
        + `./build.sh -v 2.0.0 -i 1.0.0 -l 'default|store|publisher' -q`
    - This will result in Docker images being built for each product profile provided. For example, for WSO2 Enterprise Store, there will be three images named `wso2/es-2.0.0:1.0.0`, `wso2/es-publisher-2.0.0:1.0.0`, and `wso2/es-store-2.0.0:1.0.0` for the command provided above.

## Running the Docker Images

* Docker run
    - Usage: ./run.sh -v [product-version] -i [docker-image-version] [OPTIONAL] -l [product-profile-list] [OPTIONAL] -k [key-store-password]
        + `-v [product-version]` to specify the product version
        + `-i [docker-image-version]` to specify the docker image version
        + `-l [product-profile-list]` it is optional, to specify the product profile list. If nothing is specified, it will run the default profile. 
        + `-k [key-store-password]` it is optional, to specify the key store password
    - Execute `run.sh` script and provide the product version, image version and the product profiles to be run.
        + `./run.sh -v 2.0.0 -i 1.0.0 -l 'default|store|publisher' -k 'wso2carbon'`
    - This will result in running the docker images for each product profile provided.
    
## Saving the Docker Images

* Saving the docker images
    - `Usage: ./save.sh -v [product-version] -i [docker-image-version] [OPTIONAL] -l [product_profile_list]`
        + `-v [product-version]` to specify the product version
        + `-i [docker-image-version]` to specify the docker image version
        + `-l [product-profile-list]` it is optional, to specify the product profile list. If nothing is specified, it will save the default profile.
    - Execute `save.sh` script and provide the product version, image version and the product profiles to be built.
        + `./save.sh -v 2.0.0 -i 1.0.0 -l 'default|store|publisher'`
    - This will result in saving the tar files for the docker images built for each product profile provided. For example, for WSO2 Enterprise Store, there will be three tar files saved `wso2es-2.0.0-1.0.0.tar `, `wso2es-store-2.0.0-1.0.0.tar `, and `wso2es-publisher-2.0.0-1.0.0.tar ` for the command provided above. 
    - The tar files of the docker images will be saved and found at `~/docker/images` by default.

## Secure copying the Docker Images

* Secure Copy (scp) and the docker images into the node
    - Ensure the node is up
    - Ensure the tar files of the docker images are available at `~/docker/images`
    - `Usage: ./scp.sh -h [host-list] -v [product-version] -i [docker-image-version] [OPTIONAL] -l [product_profile_list]`
        + `-h [host-list]` to specify the host node.
        + `-v [product-version]` to specify the product version
        + `-i [docker-image-version]` to specify the docker image version
        + `-l [product-profile-list]` it is optional, to specify the product profile list. If nothing is specified, it will secure copy the default profile.        
    - Execute `scp.sh` script and provide the node, product version, image version and the product profiles to the secure copied into the node.
        + `./scp.sh -h 'core@172.17.8.102' -v 2.0.0 -i 1.0.0 -l 'default|store|publisher'`
    - This will result in sending the tar files into the node and loading the docker image(s) in the node.