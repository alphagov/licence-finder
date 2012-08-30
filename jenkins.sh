#!/bin/bash -xe

export RAILS_ENV=test
export DISPLAY=":99"

git clean -fdx

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

bundle exec rake stats
bundle exec rake db:mongoid:drop
bundle exec rake
