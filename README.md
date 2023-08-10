# Seafile server packages for ARM
This repository contains a list of scripts to compile Seafile for arm/v7 and arm64.  

## Download
The latest **stable** arm builds are [here](https://github.com/lanmarc77/seafile-arm/releases).  
  
Usually these are built automatically and run through some basic automatic tests to see if the build at least installs and starts on the supported Linux distributions.  
  
## Building
The build process requires docker to be installed. It has only been tested on x86_x64 machines and builds the arm packages using docker multiarch support.  
It is designed to run with GitHub actions but can also be run manually.  

### Build Online
Just execute the action, check the build results and take the tar.gz files from the generated artifacts.  
For unknown reasons GitHub actions does not build arm/v7 packages inside the pipeline. Manual builds work though.  
  
### Build manually
Clone this repository. Make sure docker is installed and running.  
  
#### Building the server packages
Just call the build script as needed:  
  
```./manualBuildAndTest/buildAllArmv7.sh```  
(for building all arm/v7 packages for all supported distributions)  
  
``` ./manualBuildAndTest/buildAllArm64.sh```  
(for building all arm64 packages for all supported distributions)  
  
The builds should stop and display an error message if something goes wrong. Otherwise server packages are located in the ./out directory.  
Building can easily take more than one hour. Be patient.  
  
#### Testing the server packages
After the server packages have been build they can be tested. Tests include installing the server package in a brand new distribution default container and letting it run with sqlite and mysql/mariadb backends.  
  
```./manualBuildAndTest/testAllArmv7.sh```  
(for testing all arm/v7 packages for all supported distributions)  
  
```./manualBuildAndTest/testAllArm64.sh```  
(for testing all arm64 packages for all supported distributions)  
   
The tests should stop and display an error message if something goes wrong.    

## Repository structure / build system architecture
One server package build and it's test are conducted in the following way:  
  
```
   create a docker build image using the needed
       Linux distribution and architecture
       (result: runnable docker container)
                       |
                       v
    run the compilation and packaging script
            inside the build image
     (result: .tar.gz server package in ./out)
                       |
                       v
   create a docker test image using the needed
       Linux distribution and architecture
       (result: runnable docker container)
                       |
                       v
    run the test script inside the test image
         with the .tar.gz server package
       (result: ideally no error message :-))
       
```

The following directories are part of this repository (in logic order as described above):  
### .github
Contains the main.yml file. It basically only calls the below described scripts in the right order with right parameters to try to build and test all distributions and architectures.  
Usually setup to compile and test the latest Seafile version.  
### containerBuilders  
Contains one script for creating the docker container that builds the server packages as well as one for creating the docker containers that lets the tests run for the build server package.  
The two subfolders contain the dockerfile definitions for the containers.  
All scripts have small documentation on top which describe their parameters.
### compileScripts  
The buildServerPackage.sh script is the initiator which starts a fitting previously created build container and then runs one of compileSeafile*.sh in it to actually compile and build the server package. The buildServerPackage.sh script is the script which determines the Seafile version to be compiled.  
If a version specific compileSeafile script exists it is used. Otherwise the compileSeafile_default.sh script is used.  
All scripts have small documentation on top which describe their parameters.
### testScripts  
The startServerPackageTest.sh script is the initiator which starts a fitting previously built testing container and then runs one of runTest*.sh in it to actually compile and build the server package.  
If a version specific runTest script exists it is used. Otherwise the runTest_default.sh script is used.  
All scripts have small documentation on top which describe their parameters.
### githubActionsHelper  
Only contains one script currently to prepare the build host inside the GitHub pipeline to use a modern docker.
### manualBuildAndTest  
Contains script for compiling and testing manually/locally outside the GitHub pipeline.  
The buildAll*.sh scripts try to build all server packages for all distributions and architectures that are supported.  
The testAll*.sh scripts then starts testing the server packages for all distributions and architectures that are supported.  
Both scripts contain code to build the docker build and test containers.  
Usually setup to compile and test the latest Seafile version.  
The dockerReset.sh clean/resets the local docker setup and is used in the above scripts.  

## New version adjustments
TODO: explain the steps needed to adjust the scripts to compile for a new/different Seafile version.  
  
## Issues, challenges
### General topics
* Rust  
On each build the newest Rust version is downloaded and used. So while a current Rust version works this might change in the future.
* Go  
Instead of using a most likely very old Go version a specific Go version is downloaded and used. It is unclear how long older Go versions stay available for downloaded.

### Seafile v10.0.1
The following changes are done by the compileSeafile_v10.0.1.sh to fix issues:  
* Markup  
Markup was fixed to version 2.0.1 in the requirements.txt
* Compile patch  
A patch was introduced to also build the newly introduced notification-server

