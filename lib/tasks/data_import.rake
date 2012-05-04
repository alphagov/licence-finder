require 'data_importer'

desc "Import all data from the CSV files"
task :data_import => ["data_import:sectors", "data_import:business_activities", "data_import:licences"]

namespace :data_import do

  desc "Import all sector data"
  task :sectors => :environment do
    DataImporter::Sectors.update
  end
end
