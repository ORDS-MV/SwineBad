#!/bin/bash

docker run --rm -ti \
    -e USERID=$(id -u) \
    -e GROUPID=$(id -g) \
    -p 127.0.0.1:8787:8787 \
    -v "$(pwd)":/home/rstudio/SwineBad \
    rocker/geospatial:4.2.1