ARG base_image=ruby:2.7.6-slim-buster
FROM $base_image AS builder

ENV RAILS_ENV=production
# TODO: have a separate build image which already contains the build-only deps.

# Add yarn to apt sources
RUN apt-get update && apt-get install -y curl && apt-get install -y gnupg
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y build-essential yarn
RUN mkdir /app
WORKDIR /app
COPY Gemfile* .ruby-version package.json yarn.lock ./
RUN bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle install -j8 --retry=2
RUN yarn install --production --frozen-lockfile
COPY . ./
# TODO: We probably don't want assets in the image; remove this once we have a proper deployment process which uploads to (e.g.) S3.
RUN GOVUK_WEBSITE_ROOT=https://www.gov.uk \
    GOVUK_APP_DOMAIN=www.gov.uk \
    bundle exec rails assets:precompile

FROM $base_image
ENV RAILS_ENV=production GOVUK_APP_NAME=licencefinder
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y nodejs && \
    apt-get clean
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/
WORKDIR /app
CMD bundle exec puma
