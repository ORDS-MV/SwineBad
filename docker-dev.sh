#!/bin/bash

docker build --tag=swinebad:latest .
docker run --rm \
    -p 127.0.0.1:8787:8787 \
    -v "$PWD":/home/rstudio/SwineBad \
    --name=SwineBad \
    swinebad:latest
