#!/bin/sh

###############################################################################
#
# eduVPN for Android
# 
# Created for CentOS 7
#
###############################################################################

# https://developer.android.com/studio/index.html
SDK_VERSION=3859397
# https://developer.android.com/ndk/downloads/index.html
NDK_VERSION=r15c
GIT_REPO=https://github.com/eduvpn/android.git

export ANDROID_HOME="/opt/android/sdk" 
export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:/opt/android/ndk:$PATH"
export ANDROID_NDK=/opt/android/ndk
export ANDROID_NDK_HOME=/opt/android/ndk
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

# install dependencies
sudo yum -y install java-1.8.0-openjdk-devel.x86_64 git wget unzip

#for Debian:
#sudo apt -y install openjdk-8-jdk git

# Prepare /opt
sudo mkdir -p /opt/android
sudo chown "$(id -un).$(id -gn)" /opt/android

# SDK
mkdir -p /opt/android/sdk
cd /opt/android/sdk || exit
wget https://dl.google.com/android/repository/sdk-tools-linux-${SDK_VERSION}.zip
unzip -q sdk-tools-linux-${SDK_VERSION}.zip
ln -s sdk-tools-linux-${SDK_VERSION} sdk

yes | /opt/android/sdk/tools/bin/sdkmanager --licenses

# NDK
cd /opt/android || exit
wget https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip
unzip -q android-ndk-${NDK_VERSION}-linux-x86_64.zip
ln -s android-ndk-${NDK_VERSION} ndk

# App Source Download
rm -rf "${HOME}/eduvpn-app"
cd "${HOME}" || exit
git clone ${GIT_REPO} eduvpn-app

cd eduvpn-app || exit
git submodule update --init --recursive

# build the native libraries using the NDK
(
    cd ics-openvpn/main || exit
    ./misc/build-native.sh
)

./gradlew clean assembleRelease
#./gradlew clean assembleDebug

# generate a keystore
#keytool -genkey -v -keystore ~/my-release-key.jks
#/opt/android/sdk/build-tools/$(cat ~/eduvpn-app/app/build.gradle|grep buildToolsVersion|awk -F'"' '{print $2}')/apksigner sign --ks ~/my-release-key.jks ~/eduvpn-app/app/build/outputs/apk/app-basic-release-unsigned.apk
#basic-release is eduVPN app, home-release is let's connect VPN version
