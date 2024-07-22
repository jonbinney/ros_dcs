FROM ubuntu:20.04

ARG USERNAME=jbinney
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt update && apt install locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

RUN apt install -y software-properties-common
RUN add-apt-repository universe

RUN apt update && apt install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update && apt install -y \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest-cov \
  ros-dev-tools

RUN python3 -m pip install -U \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-import-order \
    flake8-quotes \
    "pytest>=5.3" \
    pytest-repeat \
    pytest-rerunfailures

# Create the user, install sudo, and give user sudo priviliges
RUN groupadd --gid $USER_GID $USERNAME
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
RUN apt update && apt install -y sudo
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
RUN chmod 0440 /etc/sudoers.d/$USERNAME

# Install ROS core packages from source
RUN mkdir -p /opt/ros/humble/src
WORKDIR /opt/ros/humble
RUN vcs import --input https://raw.githubusercontent.com/ros2/ros2/humble/ros2.repos src
RUN apt upgrade -y
RUN rosdep init
RUN rosdep update
RUN rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"
RUN colcon build --symlink-install

# Install a few extra packages we need from source
RUN mkdir -p /opt/ros/humble_extra/src
WORKDIR /opt/ros/humble_extra
COPY humble_extra.repos ./
RUN vcs import --input humble_extra.repos src
RUN . /opt/ros/humble/install/setup.sh && colcon build --symlink-install

# There must be a better way to do this.... we source the setup.sh to get the environment variables we'll need, 
# put them in a file, then we have to manually copy that file out of the container into the devcontainer folder
# so that vscode can have docker load it at startup. All so that cmake_tools and any nodes we run in the container
# will have them.
RUN . /opt/ros/humble_extra/install/setup.sh && for e in ROS_DOMAIN_ID ROS_PYTHON_VERSION PYTHONPATH CMAKE_PREFIX_PATH AMENT_PREFIX_PATH LD_LIBRARY_PATH; do echo ${e}=$(printenv $e) >> /opt/ros/humble_extra/ros.env; done
