# Whalian

This repository contains:
 -  code to build Docker container images for Debian package creation; and
 -  code to build Debian packages using such Docker container images.

## Installation

Get the Docker container image for each target distribution release. For instance, for Ubuntu 20.04:

 -  by pulling it:

    ```
    $ docker pull ghcr.io/kalrish/whalian:ubuntu-20.04
    ```

 -  by building it:

    ```
    $ git clone https://github.com/kalrish/whalian.git
    $ cd whalian
    $ sh -- build.sh ubuntu 20.04
    ```
