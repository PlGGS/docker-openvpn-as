FROM lsiobase/ubuntu:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION 
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	iptables \
	libmysqlclient-dev \
	net-tools \
	rsync \
	sqlite3 && \
 echo "**** download openvpn-as ****" && \
 if [ -z ${OPENVPNAS_VERSION+x} ]; then \
	OPENVPNAS_VERSION=$(curl -w "%{url_effective}" -ILsS -o /dev/null \
	https://openvpn.net/downloads/openvpn-as-latest-ubuntu16.amd_64.deb \
	| awk -F '(openvpn-as-|-Ubuntu16)' '{print $2}'); \
 fi && \
 mkdir /openvpn && \
 curl -o \
 /openvpn/openvpn.deb -L \
	"https://swupdate.openvpn.org/as/openvpn-as-${OPENVPNAS_VERSION}-Ubuntu16.amd_64.deb" && \
 echo "**** ensure home folder for abc user set to /config ****" && \
 usermod -d /config abc && \
 echo "**** create admin user and set default password for it ****" && \
 useradd -s /sbin/nologin admin && \
 echo "admin:password" | chpasswd && \
 rm -rf \
	/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 944/tcp 1195/udp 9444/tcp
VOLUME /config
