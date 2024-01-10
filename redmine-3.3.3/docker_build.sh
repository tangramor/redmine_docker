#!/bin/bash

docker build --build-arg RUBYMIRROR="https://cache.ruby-china.com/pub/ruby" \
    -t tangramor/redmine:3.3.3 .
