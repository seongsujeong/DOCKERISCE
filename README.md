DOCKERISCE
----------


- Functionality
This Dockerfile is for building a docker image for running ISCE in container.<br>
It automatically downloads and installs dependencies as well as the main ISCE software.

Visit https://github.com/isce-framework/isce2 for more information about ISCE.
More information about docker (what it is, how to use, etc.) is available from https://docs.docker.com


- Change log<br>
-12/19/2018 : Initial commit to Gitlab<br>
-02/12/2019 : Moving to Github & release to public right after release of ISCE

- NOTE<br>
-This image does not support GPU capability of ISCE. The author is going to try this when a GPU-equipped machine becomes available to his hands. ;)<br>
-Radarast1 processing is not supported at this point because cspice is not installed.


Last update in Feb 2019 by Seongsu Jeong (UCI)
