#!/bin/bash

docker build --build-arg RUBY_MIRROR="https://cache.ruby-china.com/pub/ruby" \
    --build-arg GEM_MIRROR="https://gems.ruby-china.com" \
    -t tangramor/redmine:5.1.5 .

