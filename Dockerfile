ARG base_image=ruby:2.7.5-slim-buster
FROM $base_image AS builder

ENV RAILS_ENV=production
# TODO: have a separate build image which already contains the build-only deps.
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y build-essential nodejs
RUN mkdir /app
WORKDIR /app
COPY Gemfile* .ruby-version ./
RUN bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle install -j8 --retry=2
COPY . ./
# TODO: We probably don't want assets in the image; remove this once we have a proper deployment process which uploads to (e.g.) S3.
RUN GOVUK_WEBSITE_ROOT=https://www.gov.uk \
    GOVUK_APP_DOMAIN=www.gov.uk \
    bundle exec rails assets:precompile

FROM $base_image
ENV RAILS_ENV=production GOVUK_APP_NAME=licence-finder
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y nodejs && \
    apt-get clean
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/
WORKDIR /app
CMD bundle exec puma
