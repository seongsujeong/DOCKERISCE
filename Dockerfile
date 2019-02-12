# DOCKERISCE
#
# Functionality: Build a docker image for running ISCE in container.
#
# Change log
# - 12/19/2018 : Initial commit to Gitlab
# - 02/12/2019 : Moving to Github & release to public right after release of ISCE
#
# Refer to Docker documentation for information about building docker image from Dockerfile.
#
# NOTE:
# - This image does not support GPU capability of ISCE. The author is going to try this when a GPU-equipped machine becomes available to his hands ;)
# - Radarast1 processing is not supported at this point because cspice is not installed 

FROM ubuntu:latest
SHELL ["/bin/bash","-c"]

LABEL author="Seongsu Jeong (seongsuj@uci.edu)" \
      description="Docker image of ISCE on Ubuntu (18.04)" \
      ISCE_version="2.3" \
      version="0.9"

#RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
#Install compilers, python, and necessary packages, GDAL #install gcc and gfortran
RUN apt-get update && \
apt-get -y install apt-utils ssh wget curl gcc g++ gfortran git screen \
vim make cmake openssl libssl-dev unzip python3-distutils python3-dev python-dev python3-pip \
pkg-config bash-completion libmotif-dev && \
mkdir /downloads


#install scons
RUN mkdir -p /downloads/scons /software/scons/3.0.1 && \
wget -O /downloads/scons/scons-3.0.1.tar.gz http://prdownloads.sourceforge.net/scons/scons-3.0.1.tar.gz && \
cd /downloads/scons && \
tar -xvf /downloads/scons/scons-3.0.1.tar.gz && \
cd /downloads/scons/scons-3.0.1 && \
python3 setup.py install --prefix=/software/scons/3.0.1 && \
rm -r /downloads/scons


#install proj
RUN mkdir -p /downloads/proj /software/proj/5.2.0 && \
wget -O /downloads/proj/proj-5.2.0.tar.gz http://download.osgeo.org/proj/proj-5.2.0.tar.gz && \
cd /downloads/proj && \
tar -xvf /downloads/proj/proj-5.2.0.tar.gz && \
cd /downloads/proj/proj-5.2.0 && \
./configure --prefix=/software/proj/5.2.0 && \
make -j10 && make install && \
echo 'export LD_LIBRARY_PATH=/software/proj/5.2.0/lib:$LD_LIBRARY_PATH' >> ~/.bashrc && \
rm -r /downloads/proj


#install GEOS
RUN mkdir -p /downloads/geos /software/geos/3.7.1 && \
wget -O /downloads/geos/geos-3.7.1.tar.bz2 http://download.osgeo.org/geos/geos-3.7.1.tar.bz2 && \
cd /downloads/geos && \
tar -xvf /downloads/geos/geos-3.7.1.tar.bz2 && \
cd /downloads/geos/geos-3.7.1 && \
./configure --prefix=/software/geos/3.7.1 && \
make -j10 && make install && \
echo 'export LD_LIBRARY_PATH=/software/geos/3.7.1/lib:$LD_LIBRARY_PATH' >> ~/.bashrc && \
rm -r /downloads/geos


#install openjpeg
RUN mkdir -p /downloads/openjpeg /software/openjpeg/2.3.0 && \
wget -O /downloads/openjpeg/v2.3.0.tar.gz https://github.com/uclouvain/openjpeg/archive/v2.3.0.tar.gz && \
cd /downloads/openjpeg && \
tar -xvf v2.3.0.tar.gz && \
cd /downloads/openjpeg/openjpeg-2.3.0/ && \
mkdir build && \
cd build/ && \
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/software/openjpeg/2.3.0 && \
make install && \
make clean && \
echo 'export LD_LIBRARY_PATH=/software/openjpeg/2.3.0/lib:$LD_LIBRARY_PATH' >> ~/.bashrc && \
rm -r /downloads/openjpeg


#install jupyter notebook and other necessary python packages
RUN python3 -m pip install --upgrade pip && \
python3 -m pip install jupyter && \
pip3 install numpy scipy matplotlib Pillow


#install fftw
RUN mkdir -p /downloads/fftw /software/fftw/3.3.8 && \
wget -O /downloads/fftw/fftw-3.3.8.tar.gz http://www.fftw.org/fftw-3.3.8.tar.gz && \
cd /downloads/fftw && \
tar -xvf fftw-3.3.8.tar.gz && \
cd /downloads/fftw/fftw-3.3.8 && \
./configure --enable-single --enable-shared --enable-avx --enable-avx2 --enable-avx512 --enable-sse --enable-sse2 --prefix=/software/fftw/3.3.8 && \
make -j10 && make install && \
echo 'export LD_LIBRARY_PATH=/software/fftw/3.3.8/lib:$LD_LIBRARY_PATH' >> ~/.bashrc && \
rm -r /downloads/fftw


#install hdf5
RUN mkdir -p /software/hdf5/1.10.4 && \
wget -O /downloads/hdf5-1.10.4.tar.gz https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.4/src/hdf5-1.10.4.tar.gz && \
cd /downloads && \
tar -xf hdf5-1.10.4.tar.gz && \
cd /downloads/hdf5-1.10.4 && \
./configure --prefix="/software/hdf5/1.10.4" && \
make -j10 && make install && \
echo 'export LD_LIBRARY_PATH=/software/hdf5/1.10.4/lib:$LD_LIBRARY_PATH' >> ~/.bashrc && \
rm -r /downloads/hdf5-1.10.4


#install gdal
#NOTE: numpy has to be available before compiling gdal. otherwise, _gdal_array will not be avilable.
RUN mkdir -p /downloads/gdal /software/gdal/2.3.2 && \
wget -O /downloads/gdal/gdal232.zip http://download.osgeo.org/gdal/2.3.2/gdal232.zip && \
cd /downloads/gdal && \
unzip gdal232.zip && \
cd /downloads/gdal/gdal-2.3.2 && \
export PATH=/software/geos/3.7.1/bin:$PATH && \
export PKG_CONFIG_PATH=/software/openjpeg/2.3.0/lib/pkgconfig:$PKG_CONFIG_PATH && \
export LD_LIBRARY_PATH=/software/openjpeg/2.3.0/lib:$LD_LIBRARY_PATH && \
./configure --prefix=/software/gdal/2.3.2 --with-python=yes --with-geos=yes --with-openjpeg=yes && \
make -j10 && make install && \
echo 'export PATH=/software/gdal/2.3.2/bin:$PATH' >> ~/.bashrc && \
echo 'export LD_LIBRARY_PATH=/software/gdal/2.3.2/lib:$LD_LIBRARY_PATH' >> ~/.bashrc && \
echo 'export GDAL_DATA=/software/gdal/2.3.2/share/gdal' >> ~/.bashrc && \
cd /downloads/gdal/gdal-2.3.2/swig/python && \
python3 setup.py build && \
mkdir -p /software/gdal/2.3.2/lib/python3.6/site-packages && \
export PYTHONPATH=/software/gdal/2.3.2/lib/python3.6/site-packages && \
python3 setup.py install --prefix=/software/gdal/2.3.2 && \
echo 'export PYTHONPATH=/software/gdal/2.3.2/lib/python3.6/site-packages:$PYTHONPATH' >> ~/.bashrc && \
rm -r /downloads/gdal


#copy isce source and configure the scons
RUN mkdir -p /software/isce-2.3 && \
wget -O /downloads/isce-2.3.zip https://github.com/isce-framework/isce2/archive/master.zip && \
ln -s /software/isce-2.3 /software/isce && \
cd /downloads && \
unzip isce-2.3.zip && \
cd /downloads/isce2-master && \
touch /downloads/isce2-master/configuration/SConfigISCE && \
echo 'PRJ_SCONS_BUILD = /downloads/isce2-master/build' >> /downloads/isce2-master/configuration/SConfigISCE && \
echo 'PRJ_SCONS_INSTALL = /software/isce-2.3' >> /downloads/isce2-master/configuration/SConfigISCE && \
echo 'LIBPATH=/usr/lib/x86_64-linux-gnu /software/fftw/3.3.8/lib /software/gdal/2.3.2/lib /software/hdf5/1.10.4/lib' >> /downloads/isce2-master/configuration/SConfigISCE && \
echo 'CPPPATH=/usr/include/python3.6m /software/fftw/3.3.8/include /software/hdf5/1.10.4/include /software/gdal/2.3.2/include' >> /downloads/isce2-master/configuration/SConfigISCE && \
echo 'FORTRANPATH = /usr/include /software/fftw/3.3.8/include' >> /downloads/isce2-master/configuration/SConfigISCE && \
echo 'FORTRAN = /usr/bin/gfortran' >> /downloads/isce2-master/configuration/SConfigISCE && \
cd /downloads/isce2-master && \
echo 'export PATH=$PATH:/software/scons/3.0.1/bin' >> ~/.bashrc

#Start building and installing ISCE
RUN cd /downloads/isce2-master && \
export PATH=/software/gdal/2.3.2/bin:/software/scons/3.0.1/bin:$PATH && \
export LD_LIBRARY_PATH=/software/fftw/3.3.8/lib:/software/gdal/2.3.2/lib:/software/hdf5/1.10.4/lib:$LD_LIBRARY_PATH && \
export GDAL_DATA=/software/gdal/2.3.2/share/gdal && \
export SCONS_CONFIG_DIR=/downloads/isce2-master/configuration && \
scons -Q install --setupfile=SConfigISCE


#Finalize the installation
RUN echo 'export ISCE_INSTALL_ROOT=/software' >> ~/.bashrc && \
echo 'export PYTHONPATH=$ISCE_INSTALL_ROOT:$PYTHONPATH' >> ~/.bashrc && \
echo 'export ISCE_HOME=$ISCE_INSTALL_ROOT/isce'  >> ~/.bashrc && \
echo 'export PATH=$ISCE_HOME/applications:$PATH' >> ~/.bashrc


#get rid of the source files
RUN cd $HOME && rm -r /downloads

#Add a user to avoid using ISCE as root
RUN useradd -m -s /bin/bash isceuser && \
cp ~/.bashrc /home/isceuser && \
chown isceuser /home/isceuser/.bashrc
USER isceuser
WORKDIR /home/isceuser

#TODO:
# - install cspice and spiceypy
# - Install grace
# - OpenCV2 does not appear to be installed / is not importable. : When trying stripmapapp.py - Does not matter too much?

