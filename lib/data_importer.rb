require 'csv'

class DataImporter

  def self.update
    fh = open_data_file
    begin
      new(fh).run
    ensure
      fh.close
    end
  end

  def self.data_file_path(filename)
    Rails.root.join('data', filename)
  end

  def initialize(fh)
    @filehandle = fh
  end

  def run
    counter = 0
    CSV.new(@filehandle, headers: true).each do |row|
      counter += process_row(row)
      done(counter, "\r")
    end
    done(counter, "\n")
  end

  private

  def done(counter, nl)
    print "Imported #{counter} #{self.class.name.split('::').last}.#{nl}"
  end
end

Dir[File.join(File.dirname(__FILE__), "data_importer/**/*.rb")].each {|f| require f}
