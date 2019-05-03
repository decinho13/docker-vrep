FROM ubuntu:16.04

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID 
    
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
      xvfb

# Setup demo environment variables
ENV HOME=/jovyan \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1400 \
    DISPLAY_HEIGHT=768 \
    RUN_XTERM=yes \
    RUN_FLUXBOX=yes

#Install ROS dependencies
RUN apt-get update && apt-get install -y \
python-rosdep python-rosinstall gnupg2 curl ca-certificates\
&& apt-get clean

# Install ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN apt-get update && apt-get install -y ros-kinetic-ros-base python-pip\
 	&& rm -rf /var/lib/apt/lists/*
RUN pip install catkin_tools

# Configure ROS
RUN rosdep init && rosdep fix-permissions && rosdep update
USER root
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
#Install V-REP
COPY . ${APP_ROOT}/bin/
RUN cd ${APP_ROOT}/bin/ &&\
    wget http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_5_0_Linux.tar.gz &&\
    tar -xf V-REP_PRO_EDU_V3_5_0_Linux.tar.gz &&\
    rm V-REP_PRO_EDU_V3_5_0_Linux.tar.gz &&\
    apt-get remove -y wget

RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
USER 10001
WORKDIR ${APP_ROOT}

EXPOSE 9000 5643
# uncomment for openshift version
#ENTRYPOINT [ "uid_entrypoint" ]
#CMD ["bash","entrypoint.sh"]
CMD ["bash","${APP_ROOT}/binentrypoint.sh"]

