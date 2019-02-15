DOCKERISCE: A dockerized ISCE on latest Ubuntu
---


- Functionality<br>
This Dockerfile is for building a docker image for running ISCE in container.<br>
It automatically downloads and installs dependencies as well as the main ISCE software.

Visit https://github.com/isce-framework/isce2 for more information about ISCE.<br>
More information about docker (what it is, how to use, etc.) is available from https://docs.docker.com

- Who is it for?<br>
For those who want to try out ISCE but do not want go through installation procedure.<br>
For those who is considering about running ISCE on cloud service. (almost every cloud services support docker)

- Dependency<br>
**NONE**. Just download the Dockerfile and generate the docker image.<br>
The Dockerfile script is going to automatically download, build, and build, and install all dependencies needed to run ISCE.


- Change log<br>
-12/19/2018 : Initial commit to Gitlab<br>
-02/12/2019 : Moving to Github & release to public right after release of ISCE

- NOTE<br>
-This image does not support GPU capability of ISCE. The author is going to try this when a GPU-equipped machine becomes available to his hands. ;)<br>
-Radarast1 processing is not supported at this point because cspice is not installed.


Last update in Feb 2019 by Seongsu Jeong (UCI)
