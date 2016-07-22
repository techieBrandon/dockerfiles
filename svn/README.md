# Dockerfile for Apache Subversion#

### Note: This Dockerfile is added to WSO2 Dockerfiles repository as there is no official docker image for SVN.

The Dockerfile defines the resources and instructions to build the Docker image for Apache SVN.

## Try it out

The cloned local copy of WSO2 Dockerfiles will be referred as `DOCKERFILES_HOME`.

* Build the docker image
    - Navigate to `<DOCKERFILES_HOME>/svn`.
    - Execute `build.sh` script and provide the version.
        + `./build.sh -v 1.0.0`

* Docker run
    - Navigate to `<DOCKERFILES_HOME>/svn`.
    - Execute `run.sh` script and provide the version.
        + `./run.sh -v 1.0.0`

* Access SVN Repo
    -  To access the SVN Repository, use the docker host IP and port 80.
        + `https://<DOCKER_HOST_IP>:80/repo`
        + `Default username - admin`
        + `Default password - admin`

* Change Username and Password of the SVN Server
    -  Execute `run.sh` script with following parameters.
        + `./run.sh -v 1.0.0 -u username -p password`

* Provide list of repositories to be created in SVN Server
    -  Execute `run.sh` script with following parameters.
        + `./run.sh -v 1.0.0 -l esb,das`

## Detailed Configuration

* [Introduction] (https://docs.wso2.com/display/DF100/Introduction+to+Docker+Images)

* [Building docker images] (https://docs.wso2.com/display/DF100/Building+Product+Docker+Images)

* [Running docker images] (https://docs.wso2.com/display/DF100/Running+and+Migrating+Images)
