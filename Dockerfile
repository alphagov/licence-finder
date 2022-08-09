ARG base_image=ghcr.io/alphagov/govuk-ruby-base:2.7.6
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:2.7.6
FROM $builder_image AS builder

RUN mkdir -p /app && ln -fs /tmp /app/tmp && ln -fs /tmp /home/app
WORKDIR /app
COPY Gemfile* .ruby-version package.json yarn.lock /app/

RUN bundle install
RUN yarn install --production --frozen-lockfile
COPY . /app
# TODO: We probably don't want assets in the image; remove this once we have a proper deployment process which uploads to (e.g.) S3.
RUN bundle exec rails assets:precompile

FROM $base_image
ENV GOVUK_APP_NAME=licencefinder

RUN mkdir -p /app && ln -fs /tmp /app/tmp && ln -fs /tmp /home/app

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/

WORKDIR /app
 
USER app

CMD bundle exec puma
