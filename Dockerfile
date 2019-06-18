FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu16.04
ENV SHELL=/bin/bash

# Install dependencies for noVNC Server    
RUN set -ex; \
    apt-get update; \
    apt-get install -y \
      bash \
      fluxbox \
      git \
      net-tools \
      novnc \
      socat \
      supervisor \
      x11vnc \
      xterm \
      xvfb \
      python-pip libtool pkg-config build-essential autoconf automake uuid-dev

# Setup demo environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1400 \
    DISPLAY_HEIGHT=768 \
    RUN_XTERM=yes \
    RUN_FLUXBOX=yes
#-------------------------------- Install Zero-MQ ----------------------------------------------------
RUN wget https://github.com/zeromq/libzmq/releases/download/v4.2.2/zeromq-4.2.2.tar.gz && \
    tar xvzf zeromq-4.2.2.tar.gz && \
    # Create make file
    cd zeromq-4.2.2 && \
    ./configure && \
    # Build and install(root permission only)
    make install && \
    # Install zeromq driver on linux
    ldconfig
RUN pip install pyzmq

# ---------------------------------------- ROS Install ------------------------------------------------------------
#Install ROS dependencies
RUN apt-get update && apt-get install -y \
python-rosdep python-rosinstall gnupg2 curl ca-certificates\
&& apt-get clean

# Install ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && apt-get install -y ros-kinetic-ros-base python-pip\
 	&& rm -rf /var/lib/apt/lists/*
RUN pip install catkin_tools

# Configure ROS
RUN rosdep init && rosdep fix-permissions && rosdep update
USER root

# ---------------------------------------- V-REP Install ------------------------------------------------------------
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}

# Install V-REP
COPY . ${APP_ROOT}/bin/
RUN cd ${APP_ROOT}/bin/ &&\
    wget http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_5_0_Linux.tar.gz &&\
    tar -xf V-REP_PRO_EDU_V3_5_0_Linux.tar.gz &&\
    rm V-REP_PRO_EDU_V3_5_0_Linux.tar.gz &&\
    apt-get remove -y wget
# Install ROS-Bridge
RUN cd ${APP_ROOT}/bin/ && mkdir ros_ws && cd ros_ws && mkdir src && cd src && \
    git clone https://github.com/lagadic/vrep_ros_bridge.git
RUN RUN /bin/bash -c '. /opt/ros/kinetic/setup.bash; cd  ~/bin/ros_ws; catkin_make; catkin_make --pkg vrep_ros_bridge --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo ;cd ~/bin/V-REP_PRO_EDU_V3_5_0_Linux;ln -s ~/bin/ros_ws/devel/lib/libv_repExtRosBridge.so'

# --------------------------------- Change User permissions for Open-Shift --------------------------------------------
RUN cd ${APP_ROOT}/bin/ && mkdir share
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
USER 10001
WORKDIR ${APP_ROOT}

EXPOSE 9000 5643

ENTRYPOINT [ "uid_entrypoint" ]
CMD ["bash","entrypoint.sh"]


