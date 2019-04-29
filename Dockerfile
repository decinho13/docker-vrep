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
RUN sudo rosdep init && sudo rosdep fix-permissions && rosdep update

#Install V-REP

RUN wget http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_5_0_Linux.tar.gz
RUN tar -xf V-REP_PRO_EDU_V3_5_0_Linux.tar.gz
RUN rm V-REP_PRO_EDU_V3_5_0_Linux.tar.gz
RUN apt-get remove -y wget

#Add NoVnc-functionality
RUN mkdir /app
COPY . /app

#Add permissions to jovyan
RUN chown -R jovyan:0 /opt/ros  && chmod -R g=u  /opt/ros 
RUN chown -R jovyan:0  /etc  && chmod -R g=u /etc 
RUN chown -R jovyan:0  /home  && chmod -R g=u /home

CMD ["sudo","sh","/app/entrypoint.sh"]

EXPOSE 9000 5643
