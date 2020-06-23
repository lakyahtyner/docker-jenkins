FROM jenkins/jenkins:lts
# if we want to install via apt
USER root

RUN echo 'root:passwd' | chpasswd

# Used to set the docker group ID
# Set to 497 by default, which is the group ID used by AWS Linux ECS Instance
ARG DOCKER_GID=497

# Create Docker Group with GID
# Set default value of 497 if DOCKER_GID set to blank string by Docker Compose
RUN groupadd -g ${DOCKER_GID:-497} docker

# Install base packages
RUN apt-get update -y && \
    apt-get install apt-transport-https curl python-dev python-setuptools gcc make libssl-dev -y && \
    easy_install pip

RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN apt-key fingerprint 0EBFCD88

# Install Docker Engine
RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    eoan \
    stable" -y && \
    add-apt-repository \
    "deb http://ftp.de.debian.org/debian sid main" -y && \
    apt-get update  -y && \
    apt-get install docker-ce docker-ce-cli containerd.io -y && \
    usermod -aG docker jenkins && \
    usermod -aG users jenkins


# Install Docker Compose
RUN pip install docker-compose && \
    pip install ansible boto boto3


# drop back to the regular jenkins user - good practice
USER jenkins
