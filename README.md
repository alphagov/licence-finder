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

#### Without using the VM

Licence Finder can be run against the live Content Store and Search API, however it needs local instances of Elasticsearch and MongoDB.

You can use docker to create these:

```
docker run -d -p 9200:9200 -e "discovery.type=single-node" --name licence-finder-elasticsearch docker.elastic.co/elasticsearch/elasticsearch:6.8.0
docker run -d -p 27017-27019:27017-27019 --name licence-finder-mongodb mongo:latest
```

Import the data and start the application:

```
export ELASTICSEARCH_URI='http://localhost:9200/'
export MONGODB_URI='mongodb://localhost/'
bundle exec rake data_import:all
bundle exec rake search:index
./startup.sh --live
```

The application will be available at http://localhost:3014

### Publishing to GOV.UK

- `bundle exec rake publishing_api:publish` will send the licence finder pages to the publishing-api.
