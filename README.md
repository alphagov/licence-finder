licence-finder
==============

To get set up with Licence Finder, first make sure you're up to date with puppet.

Load the data into MongoDB

    bundle exec rake data_import:all

Load the data into Elasticsearch

    bundle exec rake search:index
    
Migrating your Licence data to use legal_ref_id instead of correlation_id
  
    bundle exec rake licence_migrate
