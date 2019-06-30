#!/bin/sh

#
# To reproduce the error described at
# https://github.com/anestisb/android-prepare-vendor#166
# Save this script as prepare_blueline.sh in the project root and run:
#
# docker run -it \
#   --mount type=bind,src=$PWD,dst=/android-prepare-vendor \
#   -w /android-prepare-vendor \
#   ubuntu:14.04 \
#   ./prepare-blueline.sh
#

set -x

apt-get update
apt-get install -y \
    android-tools-fsutils \
    jq \
    unzip \
    wget

lsb_release -a
jq --version

#
# Copied from AOSP source tree
# https://android.googlesource.com/platform/prebuilts/jdk/jdk8
#
PATH="${PWD}/jdk8/linux-x86/bin:${PATH}"
java -version

#
# Download from https://developers.google.com/android/images#blueline
#
IMAGE="blueline-pq3a.190605.004.a1-factory-da940910.zip"
CHECKSUM="da940910bf3ac99af6ae53be3971698737ba7cb86f42b4d19e67078fd19d7a58"
echo "${CHECKSUM}  ${IMAGE}" | sha256sum -c -

rm -rf out-blueline
mkdir out-blueline
./execute-all.sh --device blueline \
    -i ${IMAGE} \
    --buildID pq3a.190605.004.a1 \
    --output out-blueline \
    --full \
    --debugfs

##
## Execution output with tracing enabled (set -x) below:
##
# + apt-get update
# 0% [Working]
# Reading package lists... Done
# ...
# + apt-get install -y android-tools-fsutils jq unzip wget
# ...
# Reading package lists... 0%
# Reading state information... Done
# ...
# The following extra packages will be installed:
#   ca-certificates libidn11 libpython-stdlib libpython2.7-minimal
#   libpython2.7-stdlib openssl python python-minimal python2.7
#   python2.7-minimal
# Suggested packages:
#   python-doc python-tk python2.7-doc binutils binfmt-support zip
# The following NEW packages will be installed:
#   android-tools-fsutils ca-certificates jq libidn11 libpython-stdlib
#   libpython2.7-minimal libpython2.7-stdlib openssl python python-minimal
#   python2.7 python2.7-minimal unzip wget
# 0 upgraded, 14 newly installed, 0 to remove and 0 not upgraded.
# Need to get 5072 kB of archives.
# After this operation, 19.6 MB of additional disk space will be used.
# ...
# 0% [Working]
# ...
# Running hooks in /etc/ca-certificates/update.d....done.
# + lsb_release -a
# No LSB modules are available.
# Distributor ID:	Ubuntu
# Description:	Ubuntu 14.04.6 LTS
# Release:	14.04
# Codename:	trusty
# + jq --version
# jq version 1.3
# + PATH=/android-prepare-vendor/jdk8/linux-x86/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# + java -version
# openjdk version "1.8.0_152-android"
# OpenJDK Runtime Environment (build 1.8.0_152-android-4627429-1)
# OpenJDK 64-Bit Server VM (build 25.152-b1, mixed mode)
# + CHECKSUM=da940910bf3ac99af6ae53be3971698737ba7cb86f42b4d19e67078fd19d7a58
# + IMAGE=blueline-pq3a.190605.004.a1-factory-da940910.zip
# + sha256sum -c -+
# echo da940910bf3ac99af6ae53be3971698737ba7cb86f42b4d19e67078fd19d7a58  blueline-pq3a.190605.004.a1-factory-da940910.zip
# blueline-pq3a.190605.004.a1-factory-da940910.zip: OK
# + rm -rf out-blueline
# + mkdir out-blueline
# + ./execute-all.sh --device blueline -i blueline-pq3a.190605.004.a1-factory-da940910.zip --buildID pq3a.190605.004.a1 --output out-blueline --full --debugfs
# [*] Setting output base to '/android-prepare-vendor/out-blueline/blueline/pq3a.190605.004.a1'
# [*] Running as root - using loopback for image mounts
# error: syntax error, unexpected QQSTRING_START, expecting $end
# ."vendor"
#  ^
# 1 compile error
# [-] json raw top string parse failed
# error: syntax error, unexpected QQSTRING_START, expecting $end
# ."extra-partitions"[]
#  ^
# 1 compile error
# [-] json top raw string string parse failed
# [*] Extracting '/android-prepare-vendor/blueline-pq3a.190605.004.a1-factory-da940910.zip'
# [*] Unzipping 'image-blueline-pq3a.190605.004.a1.zip'
# error: syntax error, unexpected QQSTRING_START, expecting $end
# ."supported-apis"[]
#  ^
# 1 compile error
# ./execute-all.sh: line 290: supportedAPIs[@]: unbound variable
#
