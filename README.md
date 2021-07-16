# Licence Finder

Licence Finder is a public facing GOV.UK application that helps users determine whether an activity they want to undertake requires a licence. Licence Finder renders the frontend of its pages, starting at https://www.gov.uk/licence-finder/sectors. Note that the [start page](https://www.gov.uk/licence-finder) is served by [Frontend][].

[Frontend]: https://github.com/alphagov/frontend

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

There is more documentation in [the docs directory](docs), for example [Adding new licences to licence-finder](docs/adding-new-licences.md) and [Notes on `gds_id`](docs/notes-on-gds-id.md).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```
bundle exec rake
```

## Licence

[MIT License](LICENCE)
