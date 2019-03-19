FROM ubuntu:16.04

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
ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1400 \
    DISPLAY_HEIGHT=768 \
    RUN_XTERM=yes \
    RUN_FLUXBOX=yes

RUN apt-get update && apt-get install -y \
python-rosdep python-rosinstall gnupg2 curl ca-certificates\
&& apt-get clean

# Install ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN apt-get update && apt-get install -y ros-kinetic-ros-base \
 	&& rm -rf /var/lib/apt/lists/*

RUN pip3 install catkin_tools

# Configure ROS
RUN sudo rosdep init && sudo rosdep fix-permissions && rosdep update
RUN echo "source /opt/ros/kinetic/setup.bash" >> /root/.bashrc


RUN wget http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_5_0_Linux.tar.gz
RUN tar -xf V-REP_PRO_EDU_V3_5_0_Linux.tar.gz
RUN rm V-REP_PRO_EDU_V3_5_0_Linux.tar.gz
RUN apt-get remove -y wget
RUN mkdir /app
COPY . /app
CMD ["sudo","bash","/app/entrypoint.sh"]
EXPOSE 9000 5643
