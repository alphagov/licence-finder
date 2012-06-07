class LicenceFacade
  def self.create_for_licences(licences)
    licences.map do |l|
      new(l)
    end
  end

  attr_reader :licence
  def initialize(licence)
    @licence = licence
  end

  def title
    @licence.name
  end
end
