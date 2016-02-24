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
#RUN apt-get install software-properties-common python-software-properties -y
#RUN add-apt-repository ppa:webupd8team/java
#RUN apt-get update -y
#RUN apt-get install oracle-java8-installer -y
#RUN apt-get install oracle-java8-set-default -y
ENV JAVA_HOME /usr/bin/java
ENV PATH $JAVA_HOME:$PATH

# Add git and cmake
RUN apt-get install -y git-core
RUN apt-get install -y cmake

# Update, upgrade and install packages
RUN \
    apt-get update && \
    apt-get -y install curl unzip python-software-properties software-properties-common

# Install Oracle Java JDK
# https://www.digitalocean.com/community/tutorials/how-to-install-java-on-ubuntu-with-apt-get
# https://github.com/dockerfile/java/blob/master/oracle-java7/Dockerfile
RUN \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java7-installer

# Install Android SDK
# https://developer.android.com/sdk/index.html#Other
RUN \
    cd /usr/local/ && \
    curl -L -O http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz && \
    tar xf android-sdk_r24.3.3-linux.tgz && \
    rm android-sdk_r24.3.3-linux.tgz

# Install Android NDK
# https://developer.android.com/tools/sdk/ndk/index.html
# https://developer.android.com/ndk/index.html
RUN \
    cd /usr/local && \
    curl -L -O http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin && \
    chmod a+x android-ndk-r10e-linux-x86_64.bin && \
    ./android-ndk-r10e-linux-x86_64.bin && \
    rm -f android-ndk-r10e-linux-x86_64.bin

# Install Gradle
RUN cd /usr/local && \
    curl -L https://services.gradle.org/distributions/gradle-2.5-bin.zip -o gradle-2.5-bin.zip && \
    unzip gradle-2.5-bin.zip

# Update & Install Android Tools
# Cloud message, billing, licensing, play services, admob, analytics
RUN \
    echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter tools --no-ui --force -a && \
    echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter platform-tools --no-ui --force -a && \
    echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter android-21 --no-ui --force -a && \
    echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter android-22 --no-ui --force -a && \
    echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter extra --no-ui --force -a

# Set PATH
ENV ANDROID_HOME=/usr/local/android-sdk-linux ANDROID_NDK_HOME=/usr/local/android-ndk-r10e JAVA_HOME=/usr/lib/jvm/java-7-oracle GRADLE_HOME=/usr/local/gradle-2.5
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_NDK_HOME/platform-tools:$ANDROID_NDK_HOME:$GRADLE_HOME/bin

# Flatten the image
# https://intercityup.com/blog/downsizing-docker-containers.html
# Cleaning APT
RUN \
    apt-get remove -y curl unzip python-software-properties software-properties-common && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/cache/oracle-jdk7-installer
	
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
