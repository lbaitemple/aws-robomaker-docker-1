FROM dorowu/ubuntu-desktop-lxde-vnc:bionic
LABEL maintainer="Tiryoh<tiryoh@gmail.com>"

RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq wget curl git build-essential vim sudo lsb-release locales bash-completion tzdata gosu python3-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*
RUN useradd --create-home --home-dir /home/ubuntu --shell /bin/bash --user-group --groups adm,sudo ubuntu && \
    echo ubuntu:ubuntu | chpasswd && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN git clone https://github.com/Tiryoh/ros_setup_scripts_ubuntu.git /tmp/ros_setup_scripts_ubuntu && \
    gosu ubuntu /tmp/ros_setup_scripts_ubuntu/ros-melodic-desktop.sh && \
    rm -rf /var/lib/apt/lists/*
ENV USER ubuntu
# Installing Colcon bundle tools
RUN pip3 install -U setuptools && pip3 install colcon-ros-bundle

RUN /bin/bash -c "echo 'export HOME=/home/ubuntu' >> /root/.bashrc && source /root/.bashrc"

# Creating catkin_ws
RUN mkdir -p /home/ubuntu/catkin_ws/src

# Set up the workspace
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && \
                  cd /home/ubuntu/catkin_ws/ && \
                  catkin_make && \
                  echo 'source /home/ubuntu/catkin_ws/devel/setup.bash' >> ~/.bashrc"

# Installing modules
COPY . /home/ubuntu/catkin_ws/src/

# Updating ROSDEP and installing dependencies
RUN apt-get update && apt-get upgrade -y
RUN cd /home/ubuntu/catkin_ws &&  rosdep install --from-paths src --ignore-src --rosdistro=melodic -y

# Adding scripts and adding permissions
#RUN cd /home/ubuntu/catkin_ws/src/scripts && \
#                chmod +x build.sh && \
#                chmod +x bundle.sh && \
#                chmod +x setup.sh

# Sourcing
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && \
                  cd /home/ubuntu/catkin_ws/ && rm -rf build devel && \
                  catkin_make"

# Dunno about this one tbh
RUN /bin/bash -c "echo 'source /home/ubuntu/catkin_ws/devel/setup.bash' >> /root/.bashrc"



