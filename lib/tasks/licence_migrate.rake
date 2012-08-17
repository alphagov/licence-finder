require 'licences_csv_migrator'
require 'licence_data_migrator'

desc "Import all data from the CSV files"
task :licence_migrate => ["licence_migrate:all"]

namespace :licence_migrate do
  desc "Migrate licence OID to legal ref no."
  task :all => :environment do
    LicencesCsvMigrator.migrate
    LicenceDataMigrator.migrate
  end

# NOTE: It's probably unwise to overwrite Licence CSV data (the original set)
#       as some of the GDS_IDs will be generated. Far better to import then update
#       with the LicenceDataMigrator
# 
#  desc "Migrate licences csv data"
#  task :csv => :environment do
#    LicencesCsvMigrator.migrate
#  end
#  
#  desc "Overwrites licences CSV with data produced licence_migrate:csv"
#  task :overwrite_csv => :environment do
#    LicencesCsvMigrator.move_files
#  end
  
  desc "Migrate activerecord licence data"
  task :data => :environment do
    LicenceDataMigrator.migrate
  end
end
