# Set the base image to Ubuntu
FROM ubuntu:14.04

# File Author / Maintainer
MAINTAINER Victor Vedovato <victor@10imaging.com>

# patch to latest
RUN apt-get update

# Avoid confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | /usr/bin/debconf-set-selections

# Add oracle-jdk8 to repositories
RUN apt-get install software-properties-common python-software-properties -y
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update -y
RUN apt-get install oracle-java8-installer -y
RUN apt-get install oracle-java8-set-default -y

ENV JAVA_HOME /usr/bin/java
ENV PATH $JAVA_HOME:$PATH

# Add Android SDK
RUN wget --progress=dot:giga http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN mv android-sdk_r24.4.1-linux.tgz /opt/
RUN cd /opt && tar xzvf ./android-sdk_r24.4.1-linux.tgz
ENV ANDROID_HOME /opt/android-sdk-linux/
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
RUN echo $PATH
RUN echo "y" | android update sdk --no-ui --filter android-21,build-tools-21.1.2
RUN chmod -R 755 $ANDROID_HOME

# Add git
RUN apt-get install -y git-core

# Add cmake
RUN apt-get install -y cmake

# Add Jenkins
RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" >> /etc/apt/sources.list
RUN apt-get update -y
# HACK: https://issues.jenkins-ci.org/browse/JENKINS-20407
RUN mkdir /var/run/jenkins
RUN apt-get install -y jenkins
RUN service jenkins stop
EXPOSE 8080
VOLUME ["/var/lib/jenkins"]
ENTRYPOINT [ "java","-jar","/usr/share/jenkins/jenkins.war" ]
## END
