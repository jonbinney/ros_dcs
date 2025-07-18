ARG ROSDISTRO=rolling
FROM ros:${ROSDISTRO}-perception
ARG USERNAME=jbinney
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# The ubuntu noble docker image that the ROS images are based on now
# includes a non-root user with GID 1000 called "ubuntu". We instead
# want to create a non-root user ourselves with the same name as on the
# host system, and same GID as on the host system (which is probably 1000)
#
# See https://askubuntu.com/questions/1513927/ubuntu-24-04-docker-images-now-includes-user-ubuntu-with-uid-gid-1000
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

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

RUN apt-get install -y gdb

# There must be a better way to do this.... we source the setup.sh to get the environment variables we'll need, 
# put them in a file, then we have to manually copy that file out of the container into the devcontainer folder
# so that vscode can have docker load it at startup. All so that cmake_tools and any nodes we run in the container
# will have them.
RUN . /opt/ros/rolling/setup.sh && for e in ROS_DOMAIN_ID ROS_PYTHON_VERSION PYTHONPATH CMAKE_PREFIX_PATH AMENT_PREFIX_PATH LD_LIBRARY_PATH; do echo ${e}=$(printenv $e) >> /opt/ros/rolling/ros.env; done

ENV SHELL /bin/bash
USER $USERNAME

# We mount our bloom config file inside this directory
RUN mkdir -p /home/$USERNAME/.config

CMD ["/bin/bash"]
