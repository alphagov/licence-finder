class LicenceFinderController < ApplicationController

  def start
  end

  def sectors
    @sectors = Sector.ascending(:name)
  end
end
