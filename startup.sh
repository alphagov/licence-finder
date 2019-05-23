#!/bin/bash

bundle install

if [[ $1 == "--live" ]] ; then
  echo "[Note] Even when using the live content-store and search-api"
  echo "licence-finder still needs a local instance of elasticsearch and"
  echo "mongodb."

  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_WEBSITE_ROOT=https://www.gov.uk \
  PLEK_SERVICE_SEARCH_URI=${PLEK_SERVICE_SEARCH_URI-https://www.gov.uk/api} \
  PLEK_SERVICE_CONTENT_STORE_URI=${PLEK_SERVICE_CONTENT_STORE_URI-https://www.gov.uk/api} \
  PLEK_SERVICE_STATIC_URI=${PLEK_SERVICE_STATIC_URI-assets.publishing.service.gov.uk} \
  bundle exec rails s -p 3014
else
  bundle exec rails s -p 3014
fi
