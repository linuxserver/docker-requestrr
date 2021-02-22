FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG REQUESTRR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nemchik"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install --no-install-recommends -y \
	libicu66 \
    unzip && \
 echo "**** install requestrr ****" && \
 mkdir -p /app/requestrr/bin && \
 if [ -z ${REQUESTRR_RELEASE+x} ]; then \
	REQUESTRR_RELEASE=$(curl -sX GET "https://api.github.com/repos/darkalfx/requestrr/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
	/tmp/requestrr.zip -L \
	"https://github.com/darkalfx/requestrr/releases/download/${REQUESTRR_RELEASE}/requestrr-linux-x64.zip" && \
 unzip \
	/tmp/requestrr.zip -d \
	/tmp/requestrr && \
 mv \
    /tmp/requestrr/requestrr-linux-x64/* \
    /app/requestrr/bin/ && \
 chmod +x /app/requestrr/bin/Requestrr.WebApi && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 4545
VOLUME /config
