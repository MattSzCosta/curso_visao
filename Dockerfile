FROM python:3.7

USER root

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libavformat-dev \
        libavcodec-dev \
        libpq-dev \
        openexr \
        libopenexr-dev \
        libatlas-base-dev \
        libv4l-dev \
        libx264-dev \
        libxvidcore-dev \
        libqt4-dev \
        libqt4-opengl-dev \
        libgtk-3-dev \
        libgtk2.0-dev \
        libdc1394-22-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install numpy

WORKDIR /
ENV OPENCV_VERSION="4.1.0"
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip ${OPENCV_VERSION}.zip \
&& mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake -DCMAKE_BUILD_TYPE=RELEASE \
  -D INSTALL_C_EXAMPLES=OFF \
  -DBUILD_opencv_cvv=OFF \
  -DINSTALL_PYTHON_EXAMPLES=ON \
  -DWITH_TBB=ON \
  -DWITH_V4L=ON \
  -DWITH_QT=ON \ 
  -DWITH_OPENGL=ON \
  -DWITH_XINE=0N \
  -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \  
  -DWITH_EIGEN=ON \  
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX=$(python3.7 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.7) \
  -DPYTHON_INCLUDE_DIR=$(python3.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.7 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  .. \
&& make install \
&& rm /${OPENCV_VERSION}.zip \
&& rm -r /opencv-${OPENCV_VERSION}
RUN ln -s \
  /usr/local/python/cv2/python-3.7/cv2.cpython-37m-x86_64-linux-gnu.so \
  /usr/local/lib/python3.7/site-packages/cv2.so


WORKDIR /app/data

# Install python dependencies
COPY requirements.txt /app/
RUN pip install -r /app/requirements.txt

COPY run-notebook.sh /app/
RUN chmod +x /app/run-notebook.sh

VOLUME /app/data
EXPOSE 8888

CMD ["/app/run-notebook.sh"]

# docker build . -t opencv4_notebook -f ./Dockerfile 
# docker run -p 8888:8888 --device=/dev/video0:/dev/video0 opencv4_notebook
