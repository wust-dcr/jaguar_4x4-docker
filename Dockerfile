ARG ROS_DISTRO=noetic
FROM ros:$ROS_DISTRO-ros-base AS pkg-builder
SHELL ["/bin/bash", "-c"]

WORKDIR /ros_ws

RUN git clone https://github.com/wust-dcr/decawave_ros --recursive src/ && \
    source /opt/ros/$ROS_DISTRO/setup.bash && \
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
    apt-get update && \
    rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y && \
    colcon build

FROM ros:$ROS_DISTRO-ros-base
ARG ROS_DISTRO

SHELL ["/bin/bash", "-c"]
WORKDIR /ros_ws

COPY --from=pkg-builder /ros_ws /ros_ws
RUN apt-get update && apt-get install -y python3-rosdep && \
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y

RUN apt-get clean && \
	apt-get remove -y \
		python3-rosdep && \
	rm -rf /var/lib/apt/lists/*