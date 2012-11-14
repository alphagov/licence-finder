# licence-finder

To get set up with Licence Finder, first make sure you're up to date with puppet.

Load the data into MongoDB

    bundle exec rake data_import:all

Load the data into Elasticsearch

    bundle exec rake search:index

Migrating your Licence data to use gds_id instead of correlation_id (This happens automatically on importing licences)

    bundle exec rake licence_migrate
