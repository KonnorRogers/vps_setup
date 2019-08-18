FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y sudo apt-utils


# copy the directory
RUN mkdir /myapp
WORKDIR /myapp
COPY . /myapp

# Create a user, and give them sudo privileges
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
USER docker
CMD /bin/bash
