FROM base/archlinux:2018.04.01

# Build arguments.
ARG VCS_REF
ARG BUILD_DATE
ARG BRINKOS_VERSION="2018.04.01"

# Labels / Metadata.
LABEL maintainer="James Brink, brink.james@gmail.com" \
    decription="brinkOS" \
    version="${BRINKOS_VERSION}" \
    org.label-schema.name="brinkos" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/jamesbrink/brinkos" \
    org.label-schema.schema-version="1.0.0-rc1"

# Create user for builds.
RUN set -xe; \
    useradd --no-create-home --shell=/bin/false build; \
    usermod -L build; \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers; \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers;

# Install all needed deps
RUN set -xe; \
    pacman -Syu --noconfirm; \
    pacman -S base base-devel cmake automake autoconf wget vim archiso openssh git nginx --noconfirm;

# If building on a debian host, dev/shm points to /run/shm
# and will fail without this directory.
RUN mkdir -p /build/archiso/work/x86_64/airootfs/run/shm; \
    mkdir -p /build/archiso/work/x86_64/airootfs/var/run/shm; \
    mkdir -p /run/shm; \
    mkdir -p /var/run/shm;

# Copy in our entrypoint and archlive and set ownership.
COPY ./archlive /build/archlive
COPY ./docker-entrypoint.sh /build/docker-entrypoint.sh

# Setup Environment variables.
ENV GTK_THEME="brinkOS-Dark" \
    SHELL_THEME="brinkOS-Dark" \
    ICON_THEME="brinkOS-Icons" \
    WALLPAPER="file:///usr/share/backgrounds/gnome/snow-white.jpg" \
    PACKAGE_PROXY=""

# Set our entrypoint which kicks off our build.
ENTRYPOINT [ "/build/docker-entrypoint.sh" ]