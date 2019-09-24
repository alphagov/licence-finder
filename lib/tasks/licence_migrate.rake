require "licence_data_migrator"

desc "Import all data from the CSV files"
task licence_migrate: ["licence_migrate:all"]

namespace :licence_migrate do
  desc "Migrate licence OID to legal ref no."
  task all: :environment do
    LicenceDataMigrator.migrate
  end
end
