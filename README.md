# licence-finder

To get set up with Licence Finder, first make sure you're up to date
with puppet.

## Loading Records

Before starting you'll need to drop the mongo database

    bundle exec rake db:mongoid:drop

Load the data into MongoDB

    bundle exec rake import:all

Load the data into Elasticsearch

    bundle exec rake search:index

## Creating Records

Each model has a corresponding rake task to easily create records.
Running `rake -T` will give a complete description of how to use each
task with the parameters required. Here's an example for creating licences:

    bundle exec rake create:licence[Licences to play music in an odd shaped building,Copyright,9000]

## Exporting Records

You can export all the data stored in your local database

    bundle exec rake export:all

Or specific models, depending on your needs

    bundle exec rake export:sector
