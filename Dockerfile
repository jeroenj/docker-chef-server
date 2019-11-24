FROM ubuntu:18.04

# Install wget and other packages
RUN set -x \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y wget ca-certificates apt-transport-https cron ifupdown rsync tzdata \
    && rm -rf /var/lib/apt/lists/*

# ARGs and ENVs for Chef Server installation
ARG CHEF_SERVER_VERSION=12.19.31
ARG CHEF_SERVER_DOWNLOAD_SHA256=bbf6127e03d10154e28b1270869731b38bd5a0981c9f9cb96f973c290d14c4df
ENV CHEF_SERVER_VERSION ${CHEF_SERVER_VERSION}
ENV CHEF_SERVER_DOWNLOAD_URL https://packages.chef.io/files/stable/chef-server/"$CHEF_SERVER_VERSION"/ubuntu/18.04/chef-server-core_"$CHEF_SERVER_VERSION"-1_amd64.deb
ENV CHEF_SERVER_DOWNLOAD_SHA256 ${CHEF_SERVER_DOWNLOAD_SHA256}

# Download and install the Chef-Server package
RUN set -x \
    && wget --no-verbose -O chef-server-core_"$CHEF_SERVER_VERSION"-1_amd64.deb "$CHEF_SERVER_DOWNLOAD_URL" \
    && echo "$CHEF_SERVER_DOWNLOAD_SHA256 chef-server-core_$CHEF_SERVER_VERSION-1_amd64.deb" | sha256sum -c - \
    && dpkg -i chef-server-core_"$CHEF_SERVER_VERSION"-1_amd64.deb \
    && rm chef-server-core_"$CHEF_SERVER_VERSION"-1_amd64.deb

# Create the `/var/opt/chef-backup` directory for mountpoint
RUN set -x \
    && mkdir -p /var/opt/chef-backup

# Volumes
VOLUME ["/etc/opscode", "/var/opt/opscode", "/var/opt/chef-backup"]

# Copy Entrypoint file
ADD scripts/* /

# Set Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Expose ports
EXPOSE 80 443

# Set WORKDIR
WORKDIR /opt/opscode
