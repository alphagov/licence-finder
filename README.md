# licence-finder

To get set up with Licence Finder, first make sure you're up to date with puppet.

Load the data into MongoDB

    bundle exec rake data_import:all

Load the data into Elasticsearch

    bundle exec rake search:index

Migrating your Licence data to use gds_id instead of correlation_id (This happens automatically on importing licences)

    bundle exec rake licence_migrate

### Running the application

Using bowler on the VM from cd /var/govuk/development/:

```
bowl licencefinder
```

If you are using the GDS development virtual machine then the application will be available on the host at http://licencefinder.dev.gov.uk/licence-finder

### Publishing to GOV.UK

- `bundle exec rake panopticon:register` will send the licence finder pages to panopticon. Panopticon will register the URL.

### Search indexing

- `bundle exec rake rummager:index_all` will send the data to Rummager for indexing in search.
