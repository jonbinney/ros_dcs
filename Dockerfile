ARG ROSDISTRO=humble
FROM osrf/ros:${ROSDISTRO}-desktop
ARG USERNAME=jbinney
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y python3-pip

# For releasing ROS packages (we still use catkin_generate_changelog and 
# catkin_prepare_release in ros2)
RUN apt-get install -y python3-catkin-pkg python3-bloom

ENV SHELL /bin/bash

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

# We mount our bloom config file inside this directory
RUN mkdir -p /home/$USERNAME/.config

CMD ["/bin/bash"]
